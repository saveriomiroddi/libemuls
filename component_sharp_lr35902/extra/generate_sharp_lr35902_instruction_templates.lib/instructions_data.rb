module InstructionsData
  include FormattingHelpers

  extend self

  REGISTER_OPERAND_8 = :register_8
  REGISTER_OPERAND_16 = :register_16
  IMMEDIATE_OPERAND_8 = :immediate_8
  IMMEDIATE_OPERAND_16 = :immediate_16

  REMOVED_OPERAND = :removed

  REGISTERS_8B = %w[A B C D E H L]
  REGISTERS_16B = %w[BC DE HL]

  # Base case of testing code for an operation that affects the flags. If there are flags that have a
  # fixed outcome, they're included (autogenerated).
  #
  BASE = :base

  # Code generated is not efficient, in a few ways. This can be optimized, but it's not the scope of
  # this tool.

  # Specifications:
  #
  # ## Predefined data
  #
  # - operation_code:        (optional) if `zf` is set, then a boolean variable called `carry` must be set
  # - transform_opcode_data: (optional) Executed after fetching the opcode data from the JSON; destructive.
  # - testing:               Proc taking (*operands), returns a hash {"flag_type" => {:extra_instruction_bytes, :presets, :expectations}}
  #
  # ## Computed data
  #
  # - instruction_size
  # - flags_data
  # - operand_types:         Array of `OperandType` instances
  #
  # Pan doc groups some instructions that have different operand types together, e.g. `LD r1, r2`,
  # `LD r, n`, `LD r1, (r2)` and so on; this is correct in a way, but we need more a more specific
  # taxonomy, so the families as represented here are more granular.
  #
  INSTRUCTIONS_DATA = {
    "LD r, n" => {
      prefixed: false,
      opcodes: [
        0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E,
        0x3E
      ],
      operation_code: <<~RUST,
        *register = *immediate;
      RUST
      testing: ->(register, _) {
        {
          BASE => {
            extra_instruction_bytes: [0x21],
            expectations: "#{register} => 0x21,"
          }
        }
      }
    },
    # Includes cases where r1 == r2.
    #
    "LD r1, r2" => {
      prefixed: false,
      opcodes: [
        0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x41, 0x42, 0x43, 0x44, 0x45, 0x48,
        0x4A, 0x4B, 0x4C, 0x4D, 0x50, 0x51, 0x53, 0x54, 0x55, 0x58, 0x59, 0x5A,
        0x5C, 0x5D, 0x60, 0x61, 0x62, 0x63, 0x65, 0x68, 0x69, 0x6A, 0x6B, 0x6C,
        0x47, 0x4F, 0x57, 0x5F, 0x67, 0x6F,
        0x7F, 0x40, 0x49, 0x52, 0x5B, 0x64, 0x6D
      ],
      operation_code: <<~RUST,
        *dst_register = unsafe { *src_register };
      RUST
      testing: ->(register1, register2) {
        {
          BASE => {
            presets: "cpu.#{register2} = 0x21;",
            expectations: "#{register1} => 0x21,",
          }
        }
      }
    },
    # Includes some cases where r1 is part of r2 (HL).
    #
    "LD r1, (r2)" => {
      prefixed: false,
      opcodes: [
        0x46, 0x4E, 0x56, 0x5E, 0x7E, 0x0A, 0x1A, 0x66, 0x6E
      ],
        operation_code: <<~RUST,
          let address = Self::compose_address(*src_register_high, *src_register_low);
          unsafe { *dst_register = internal_ram[address] };
        RUST
      testing: ->(register1, register2) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0x21;
              cpu.#{register2[0]} = 0x0C;
              cpu.#{register2[1]} = 0xAF;
            RUST
            expectations: "#{register1} => 0x21,",
          }
        }
      }
    },
    # Includes some cases where r2 is part of r1 (HL).
    #
    "LD (r1), r2" => {
      prefixed: false,
      opcodes: [
        0x70, 0x71, 0x72, 0x73, 0x74, 0x75,
        0x02, 0x12, 0x77
      ],
      operation_code: <<~RUST,
        let address = Self::compose_address(*dst_register_high, *dst_register_low);
        internal_ram[address] = unsafe { *src_register };
      RUST
      testing: ->(register1, register2) {
        {
          BASE => {
            # In the cases where r2 is part of r1, an r1 assignment overwrites r2, so that the memory
            # expectation can be kept the same.
            #
            presets: <<~RUST,
              cpu.#{register2} = 0x21;
              cpu.#{register1[0]} = 0x0C;
              cpu.#{register1[1]} = 0xAF;

              let expected_value = cpu.#{register2};
            RUST
            expectations: "mem[0x0CAF] => expected_value,",
          }
        }
      }
    },
    "LD (r), n" => {
      prefixed: false,
      opcodes: [
        0x36
      ],
      operation_code: <<~RUST,
        let address = Self::compose_address(*register_high, *register_low);
        internal_ram[address] = *immediate;
      RUST
      testing: ->(register, _) {
        {
          BASE => {
            extra_instruction_bytes: [0x21],
            presets: <<~RUST,
              cpu.#{register[0]} = 0x0C;
              cpu.#{register[1]} = 0xAF;
            RUST
            expectations: "mem[0x0CAF] => 0x21,",
          }
        }
      }
    },
    "LD A, (nn)" => {
      prefixed: false,
      opcodes: [0xFA],
      operation_code: <<~RUST,
        let address = Self::compose_address(*immediate_high, *immediate_low);
        *register = internal_ram[address];
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            extra_instruction_bytes: [0xAF, 0x0C],
            presets: "cpu.internal_ram[0x0CAF] = 0x21;",
            expectations: "A => 0x21,",
          }
        }
      }
    },
    "LD (nn), A" => {
      prefixed: false,
      opcodes: [0xEA],
      operation_code: <<~RUST,
        let address = Self::compose_address(*dst_immediate_high, *dst_immediate_low);
        internal_ram[address] = *register;
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            extra_instruction_bytes: [0xAF, 0x0C],
            presets: "cpu.A = 0x21;",
            expectations: "mem[0x0CAF] => 0x21,",
          }
        }
      }
    },
    "LD A, (C)" => {
      prefixed: false,
      opcodes: [0xF2],
      operation_code: <<~RUST,
        let address = 0xFF00 + *src_register as usize;
        *dst_register = internal_ram[address];
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.C = 0x13;
              cpu.internal_ram[0xFF13] = 0x21;
            RUST
            expectations: "A => 0x21,",
          }
        }
      }
    },
    "LD (C), A" => {
      prefixed: false,
      opcodes: [0xE2],
      operation_code: <<~RUST,
        let address = 0xFF00 + *dst_register as usize;
        internal_ram[address] = *src_register;
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.A = 0x21;
              cpu.C = 0x13;
            RUST
            expectations: "mem[0xFF13] => 0x21,",
          }
        }
      }
    },
    "LDD A, (HL)" => {
      prefixed: false,
      opcodes: [0x3A],
      transform_opcode_data: ->(data) do
        # The source data uses "LD", but includes a "decrement" attribute in the operand.
        data["mnemonic"] = "LDD"
      end,
      operation_code: <<~RUST,
        let address = Self::compose_address(*src_register_high, *src_register_low);
        *dst_register = internal_ram[address];

        let (new_value_low, carry) = src_register_low.overflowing_sub(1);
        *src_register_low = new_value_low;

        if carry {
          let (new_value_high, _) = src_register_high.overflowing_sub(1);
          *src_register_high = new_value_high;
        }
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.H = 0x00;
              cpu.L = 0x00;
              cpu.internal_ram[0x0000] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x21,
              H => 0xFF,
              L => 0xFF,
            RUST
          }
        }
      }
    },
    "LDD (HL), A" => {
      prefixed: false,
      opcodes: [0x32],
      transform_opcode_data: ->(data) do
        # Same considerations as `LDD A, (HL)`
        data["mnemonic"] = "LDD"
      end,
      operation_code: <<~RUST,
        let address = Self::compose_address(*dst_register_high, *dst_register_low);
        internal_ram[address] = *src_register;

        let (new_value_low, carry) = dst_register_low.overflowing_sub(1);
        *dst_register_low = new_value_low;

        if carry {
          let (new_value_high, _) = dst_register_high.overflowing_sub(1);
          *dst_register_high = new_value_high;
        }
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.A = 0x21;
              cpu.H = 0x00;
              cpu.L = 0x00;
            RUST
            expectations: <<~RUST
              H => 0xFF,
              L => 0xFF,
              mem[0x0000] => 0x21,
            RUST
          }
        }
      }
    },
    "LDI A, (HL)" => {
      prefixed: false,
      opcodes: [0x2A],
      transform_opcode_data: ->(data) do
        # Similar considerations as `LDD A, (HL)`
        data["mnemonic"] = "LDI"
      end,
      operation_code: <<~RUST,
        let address = Self::compose_address(*src_register_high, *src_register_low);
        *dst_register = internal_ram[address];

        let (new_value_low, carry) = src_register_low.overflowing_add(1);
        *src_register_low = new_value_low;

        if carry {
          let (new_value_high, _) = src_register_high.overflowing_add(1);
          *src_register_high = new_value_high;
        }
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.H = 0xFF;
              cpu.L = 0xFF;
              cpu.internal_ram[0xFFFF] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x21,
              H => 0x00,
              L => 0x00,
            RUST
          }
        }
      }
    },
    "LDI (HL), A" => {
      prefixed: false,
      opcodes: [0x22],
      transform_opcode_data: ->(data) do
        # Same considerations as `LDD A, (HL)`
        data["mnemonic"] = "LDI"
      end,
      operation_code: <<~RUST,
        let address = Self::compose_address(*dst_register_high, *dst_register_low);
        internal_ram[address] = *src_register;

        let (new_value_low, carry) = dst_register_low.overflowing_add(1);
        *dst_register_low = new_value_low;

        if carry {
          let (new_value_high, _) = dst_register_high.overflowing_add(1);
          *dst_register_high = new_value_high;
        }
      RUST
      testing: ->(_, _) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.A = 0x21;
              cpu.H = 0xFF;
              cpu.L = 0xFF;
            RUST
            expectations: <<~RUST
              H => 0x00,
              L => 0x00,
              mem[0xFFFF] => 0x21,
            RUST
          }
        }
      }
    },
    "INC r" => {
      prefixed: false,
      opcodes: [0x3C, 0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C],
      operation_code: <<~RUST,
        let (new_value, carry) = register.overflowing_add(1);
        *register = new_value;

        if new_value & 0b0000_1111 == 0b000_0000 {
          *hf = true;
        }
      RUST
      testing: ->(register) {
        {
          BASE => {
            presets: "cpu.#{register} = 0x21;",
            expectations: <<~RUST
              #{register} => 0x22,
            RUST
          },
          'Z' => {
            presets: "cpu.#{register} = 0xFF;",
            expectations: <<~RUST
              #{register} => 0x00,
              zf => 1,
              hf => 1,
            RUST
          },
          'H' => {
            presets: "cpu.#{register} = 0x1F;",
            expectations: <<~RUST
              #{register} => 0x20,
              hf => 1,
            RUST
          }
        }
      }
    },
    "INC (HL)" => {
      prefixed: false,
      opcodes: [0x34],
      operation_code: <<~RUST,
        let address = Self::compose_address(*register_high, *register_low);

        let (new_value, carry) = internal_ram[address].overflowing_add(1);
        internal_ram[address] = new_value;

        if new_value & 0b0000_1111 == 0b000_0000 {
          *hf = true;
        }
      RUST
      testing: ->(_) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0x21;
              cpu.H = 0x0C;
              cpu.L = 0xAF;
            RUST
            expectations: <<~RUST
              mem[0x0CAF] => 0x22,
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0xFF;
              cpu.H = 0x0C;
              cpu.L = 0xAF;
            RUST
            expectations: <<~RUST
              mem[0x0CAF] => 0x0,
              zf => 1,
              hf => 1,
            RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0x1F;
              cpu.H = 0x0C;
              cpu.L = 0xAF;
            RUST
            expectations: <<~RUST
              mem[0x0CAF] => 0x20,
              hf => 1,
            RUST
          }
        }
      }
    },
    "NOP" => {
      prefixed: false,
      opcodes: [0x00],
      testing: -> {
        {
          BASE => {}
        }
      }
    },
  }
end
