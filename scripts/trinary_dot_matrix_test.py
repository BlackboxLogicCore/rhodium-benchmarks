#!/usr/bin/env python3
import concurrent.futures
import hashlib
import json
import math
from pathlib import Path

BLOCK_BYTES = 99
TRITS_PER_BLOCK = 500
TRITS_PER_PACKED_BYTE = 5
PACKED_BYTES_PER_BLOCK = 100
WORKERS = 32


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def encode_block(block: bytes) -> bytes:
    if len(block) < BLOCK_BYTES:
        block = block + b"\x00" * (BLOCK_BYTES - len(block))
    n = int.from_bytes(block, "big")
    trits = [0] * TRITS_PER_BLOCK
    for i in range(TRITS_PER_BLOCK - 1, -1, -1):
        n, r = divmod(n, 3)
        trits[i] = r
    if n:
        raise RuntimeError("TRINARY_BLOCK_OVERFLOW")

    out = bytearray(PACKED_BYTES_PER_BLOCK)
    j = 0
    for i in range(0, TRITS_PER_BLOCK, TRITS_PER_PACKED_BYTE):
        v = 0
        for t in trits[i:i + TRITS_PER_PACKED_BYTE]:
            v = v * 3 + t
        out[j] = v
        j += 1
    return bytes(out)


def decode_block(packed: bytes) -> bytes:
    if len(packed) != PACKED_BYTES_PER_BLOCK:
        raise RuntimeError("BAD_PACKED_BLOCK")
    trits = []
    for v in packed:
        if v >= 243:
            raise RuntimeError("INVALID_TRINARY_SYMBOL_PACK")
        group = [0] * TRITS_PER_PACKED_BYTE
        for i in range(TRITS_PER_PACKED_BYTE - 1, -1, -1):
            v, r = divmod(v, 3)
            group[i] = r
        trits.extend(group)

    n = 0
    for t in trits:
        n = n * 3 + t
    if n >= (1 << (8 * BLOCK_BYTES)):
        raise RuntimeError("DECODED_BLOCK_OUT_OF_RANGE")
    return n.to_bytes(BLOCK_BYTES, "big")


def main():
    source_path = Path("sample.bin")
    source = source_path.read_bytes()
    if not source:
        raise SystemExit("EMPTY_SOURCE")

    blocks = [
        source[i:i + BLOCK_BYTES]
        for i in range(0, len(source), BLOCK_BYTES)
    ]

    with concurrent.futures.ProcessPoolExecutor(max_workers=WORKERS) as pool:
        encoded_blocks = list(pool.map(encode_block, blocks, chunksize=max(1, len(blocks)//(WORKERS*4))))

    # 4-byte exact source length is part of the standalone signal.
    if len(source) >= 2**32:
        raise SystemExit("SOURCE_TOO_LARGE_FOR_TEST_HEADER")
    signal = len(source).to_bytes(4, "big") + b"".join(encoded_blocks)

    payload = signal[4:]
    packed_blocks = [
        payload[i:i + PACKED_BYTES_PER_BLOCK]
        for i in range(0, len(payload), PACKED_BYTES_PER_BLOCK)
    ]

    with concurrent.futures.ProcessPoolExecutor(max_workers=WORKERS) as pool:
        decoded_blocks = list(pool.map(decode_block, packed_blocks, chunksize=max(1, len(packed_blocks)//(WORKERS*4))))

    decoded = b"".join(decoded_blocks)[:int.from_bytes(signal[:4], "big")]

    source_hash = sha256(source)
    decoded_hash = sha256(decoded)
    if source_hash != decoded_hash or source != decoded:
        raise SystemExit("ROUNDTRIP_FAIL")

    trit_count = len(blocks) * TRITS_PER_BLOCK
    packed_bytes = len(signal)
    delta = packed_bytes - len(source)
    result = {
        "status": "PASS",
        "states": 3,
        "workers": WORKERS,
        "source_bytes": len(source),
        "source_sha256": source_hash,
        "trits": trit_count,
        "packed_signal_bytes": packed_bytes,
        "delta_bytes": delta,
        "delta_percent": (delta / len(source)) * 100.0,
        "roundtrip_bit_identical": True,
        "decoded_sha256": decoded_hash,
        "packing": "5_trits_per_byte",
        "block_bytes": BLOCK_BYTES,
        "trits_per_block": TRITS_PER_BLOCK,
        "length_header_bytes": 4,
        "information_capacity_bits_per_trit": math.log2(3),
    }

    Path("evidence").mkdir(exist_ok=True)
    Path("evidence/trinary-dot-matrix-result.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
