module InstructionsCode
  # Base case of testing code for an operation that affects the flags. If there are flags that have a
  # fixed outcome, they're included (autogenerated).
  #
  BASE = "base"

  # Code generated is not efficient, in a few ways. This can be optimized, but it's not the scope of
  # this tool.

  # Specifications:
  #
  # ## Predefined data
  #
  # - operation_code:        (optional) if `zf` is set, then a boolean variable called `carry` must be set
  # - testing:               Proc taking (*operands), returns a hash {"flag_type" => {:extra_instruction_bytes, :presets, :expectations}}
  #
  # ## Computed data
  #
  # - instruction_size
  # - flags_data
  #
  INSTRUCTIONS_CODE = {
    "LD r, n" => {
      operation_code: <<~RUST,
        self[dst_register] = *immediate;
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
    "LD r1, r2" => {
      operation_code: <<~RUST,
        self[dst_register] = self[src_register];
      RUST
      testing: ->(register1, register2) {
        {
          BASE => {
            presets: "cpu[Reg8::#{register2}] = 0x21;",
            expectations: "#{register1} => 0x21,",
          }
        }
      }
    },
    "LD r1, (rr2)" => {
        operation_code: <<~RUST,
          self[dst_register] = self.internal_ram[self[src_register] as usize];
        RUST
      testing: ->(register1, register2) {
        {
          BASE => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0x21;
              cpu[Reg16::#{register2}] = 0x0CAF;
            RUST
            expectations: "#{register1} => 0x21,",
          }
        }
      }
    },
    "LD (rr1), r2" => {
      operation_code: <<~RUST,
        self.internal_ram[self[dst_register] as usize] = self[src_register];
      RUST
      testing: ->(register1, register2) {
        {
          BASE => {
            # In the cases where r2 is part of r1, an r1 assignment overwrites r2, so that the memory
            # expectation can be kept the same.
            #
            presets: <<~RUST,
              cpu[Reg8::#{register2}] = 0x21;
              cpu[Reg16::#{register1}] = 0x0CAF;

              let expected_value = cpu[Reg8::#{register2}];
            RUST
            expectations: "mem[0x0CAF] => [expected_value],",
          }
        }
      }
    },
    "LD (HL), n" => {
      operation_code: <<~RUST,
        self.internal_ram[self[Reg16::HL] as usize] = *immediate;
      RUST
      testing: ->(_) {
        {
          BASE => {
            extra_instruction_bytes: [0x21],
            presets: <<~RUST,
              cpu[Reg16::HL] = 0x0CAF;
            RUST
            expectations: "mem[0x0CAF] => [0x21],",
          }
        }
      }
    },
    "LD A, (nn)" => {
      operation_code: <<~RUST,
        self[Reg8::A] = self.internal_ram[*immediate as usize];
      RUST
      testing: ->(_) {
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
      operation_code: <<~RUST,
        self.internal_ram[*immediate as usize] = self[Reg8::A];
      RUST
      testing: ->(_) {
        {
          BASE => {
            extra_instruction_bytes: [0xAF, 0x0C],
            presets: "cpu[Reg8::A] = 0x21;",
            expectations: "mem[0x0CAF] => [0x21],",
          }
        }
      }
    },
    "LD A, (C)" => {
      operation_code: <<~RUST,
        let address = 0xFF00 + self[Reg8::C] as usize;
        self[Reg8::A] = self.internal_ram[address];
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::C] = 0x13;
              cpu.internal_ram[0xFF13] = 0x21;
            RUST
            expectations: "A => 0x21,",
          }
        }
      }
    },
    "LD (C), A" => {
      operation_code: <<~RUST,
        let address = 0xFF00 + self[Reg8::C] as usize;
        self.internal_ram[address] = self[Reg8::A];
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg8::C] = 0x13;
            RUST
            expectations: "mem[0xFF13] => [0x21],",
          }
        }
      }
    },
    "LDD A, (HL)" => {
      operation_code: <<~RUST,
        self[Reg8::A] = self.internal_ram[self[Reg16::HL] as usize];

        let (new_value, _) = self[Reg16::HL].overflowing_sub(1);
        self[Reg16::HL] = new_value;
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg16::HL] = 0x0000;
              cpu.internal_ram[0x0000] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x21,
              HL => 0xFFFF,
            RUST
          }
        }
      }
    },
    "LDD (HL), A" => {
      operation_code: <<~RUST,
        self.internal_ram[self[Reg16::HL] as usize] = self[Reg8::A];

        let (new_value, _) = self[Reg16::HL].overflowing_sub(1);
        self[Reg16::HL] = new_value;
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg16::HL] = 0x0000;
            RUST
            expectations: <<~RUST
              HL => 0xFFFF,
              mem[0x0000] => [0x21],
            RUST
          }
        }
      }
    },
    "LDI A, (HL)" => {
      operation_code: <<~RUST,
        self[Reg8::A] = self.internal_ram[self[Reg16::HL] as usize];

        let (new_value, _) = self[Reg16::HL].overflowing_add(1);
        self[Reg16::HL] = new_value;
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg16::HL] = 0xFFFF;
              cpu.internal_ram[0xFFFF] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x21,
              HL => 0x0000,
            RUST
          }
        }
      }
    },
    "LDI (HL), A" => {
      operation_code: <<~RUST,
        self.internal_ram[self[Reg16::HL] as usize] = self[Reg8::A];

        let (new_value, _) = self[Reg16::HL].overflowing_add(1);
        self[Reg16::HL] = new_value;
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg16::HL] = 0xFFFF;
            RUST
            expectations: <<~RUST
              HL => 0x0000,
              mem[0xFFFF] => [0x21],
            RUST
          }
        }
      }
    },
    "LDH (n), A" => {
      operation_code: <<~RUST,
        let address = 0xFF00 + *immediate as usize;
        self.internal_ram[address] = self[Reg8::A];
      RUST
      testing: ->(_) {
        {
          BASE => {
            extra_instruction_bytes: [0x13],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
            RUST
            expectations: "mem[0xFF13] => [0x21],",
          }
        }
      }
    },
    "LDH A, (n)" => {
      operation_code: <<~RUST,
        let address = 0xFF00 + *immediate as usize;
        self[Reg8::A] = self.internal_ram[address];
      RUST
      testing: ->(_) {
        {
          BASE => {
            extra_instruction_bytes: [0x13],
            presets: <<~RUST,
              cpu.internal_ram[0xFF13] = 0x21;
            RUST
            expectations: "A => 0x21,",
          }
        }
      }
    },
    "LD rr, nn" => {
      operation_code: <<~RUST,
        self[dst_register] = *immediate;
      RUST
      testing: ->(register, _) {
        {
          BASE => {
            extra_instruction_bytes: [0xFE, 0xCA],
            expectations: <<~RUST
              #{register} => 0xCAFE,
            RUST
          }
        }
      }
    },
    "LD SP, HL" => {
      operation_code: <<~RUST,
        self[Reg16::SP] = self[Reg16::HL];
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg16::HL] = 0xCAFE;
            RUST
            expectations: <<~RUST
              SP => 0xCAFE,
            RUST
          }
        }
      }
    },
    "LDHL SP, n" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg16::SP];
        // Ugly, but required, conversions.
        let operand2 = *immediate as i8 as i16 as u16;

        let (result, _) = operand1.overflowing_add(operand2);
        self[Reg16::HL] = result;
      RUST
      testing: ->(_) {
        {
          "#{BASE}: positive immediate" => {
            extra_instruction_bytes: [0x01],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0x2100;
            RUST
            expectations: <<~RUST
              HL => 0x2101,
            RUST
          },
          "#{BASE}: negative immediate" => {
            extra_instruction_bytes: [0xFF],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0x2100;
            RUST
            expectations: <<~RUST
              HL => 0x20FF,
            RUST
          },
          "H" => {
            extra_instruction_bytes: [0x01],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xCAEF;
            RUST
            expectations: <<~RUST
              HL => 0xCAF0,
              hf => true,
            RUST
          },
          "H: negative immediate" => {
            extra_instruction_bytes: [0xE1],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xCA0F;
            RUST
            expectations: <<~RUST
              HL => 0xC9F0,
              hf => true,
            RUST
          },
          "C" => {
            extra_instruction_bytes: [0x10],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xCAFF;
            RUST
            expectations: <<~RUST
              HL => 0xCB0F,
              cf => true,
            RUST
          },
          "C: negative immediate" => {
            extra_instruction_bytes: [0xE0],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xCA2F;
            RUST
            expectations: <<~RUST
              HL => 0xCA0F,
              cf => true,
            RUST
          },
        }
      }
    },
    "LD (nn), SP" => {
      operation_code: <<~RUST,
        self.internal_ram[*immediate as usize] = self[Reg16::SP] as u8;
        self.internal_ram[*immediate as usize + 1] = (self[Reg16::SP] >> 8) as u8;
      RUST
      testing: ->(_) {
        {
          BASE => {
            extra_instruction_bytes: [0xFE, 0xCA],
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xBEEF;
            RUST
            expectations: <<~RUST
              mem[0xCAFE] => [0xEF, 0xBE],
            RUST
          }
        }
      }
    },
    "PUSH rr" => {
      operation_code: <<~RUST,
        let (new_sp, _) = self[Reg16::SP].overflowing_sub(2);
        self[Reg16::SP] = new_sp;

        let pushed_bytes = self[dst_register].to_le_bytes();
        self.internal_ram[new_sp as usize..new_sp as usize + 2].copy_from_slice(&pushed_bytes);
      RUST
      testing: ->(register) {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg16::#{register}] = 0xBEEF;
              cpu[Reg16::SP] = 0xCAFE;
            RUST
            expectations: <<~RUST
              SP => 0xCAFC,
              mem[0xCAFC] => [0xEF, 0xBE],
            RUST
          },
          "#{BASE}: wraparound" => {
            presets: <<~RUST,
              cpu[Reg16::#{register}] = 0xBEEF;
            RUST
            expectations: <<~RUST
              SP => 0xFFFE,
              mem[0xFFFE] => [0xEF, 0xBE],
            RUST
          },
        }
      }
    },
    "POP rr" => {
      operation_code: <<~RUST,
        let source_bytes = self.internal_ram[self[Reg16::SP] as usize..self[Reg16::SP] as usize + 2].try_into().unwrap();
        self[dst_register] = u16::from_le_bytes(source_bytes);

        let (result, _) = self[Reg16::SP].overflowing_add(2);
        self[Reg16::SP] = result;
      RUST
      testing: ->(register) {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xCAFE;

              let address = cpu[Reg16::SP] as usize;
              cpu.internal_ram[address..address + 2].copy_from_slice(&[0xEF, 0xBE]);
            RUST
            expectations: <<~RUST
              #{register} => 0xBEEF,
              SP => 0xCB00,
            RUST
          },
          "#{BASE}: wraparound" => {
            presets: <<~RUST,
              cpu[Reg16::SP] = 0xFFFE;

              let address = cpu[Reg16::SP] as usize;
              cpu.internal_ram[address..address + 2].copy_from_slice(&[0xEF, 0xBE]);
            RUST
            expectations: <<~RUST
              #{register} => 0xBEEF,
              SP => 0x0000,
            RUST
          },
        }
      }
    },
    "ADD A, r" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A];
        let operand2 = self[dst_register];

        let (result, carry) = operand1.overflowing_add(operand2);
        self[Reg8::A] = result;

        self.set_flag(Flag::c, carry);
      RUST
      # In some UTs, the two registers are set to the same value in order to handle `ADD A, A`.
      #
      testing: ->(register) {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg8::#{register}] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x42,
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu[Reg8::#{register}] = 0;
            RUST
            expectations: <<~RUST
              A => 0x00,
              zf => true,
            RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x18;
              cpu[Reg8::#{register}] = 0x18;
            RUST
            expectations: <<~RUST
              A => 0x30,
              hf => true,
            RUST
          },
          'C' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x90;
              cpu[Reg8::#{register}] = 0x90;
            RUST
            expectations: <<~RUST
              A => 0x20,
              cf => true,
            RUST
          }
        }
      }
    },
    "ADD A, (HL)" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A];
        let operand2 = self.internal_ram[self[Reg16::HL] as usize];

        let (result, carry) = operand1.overflowing_add(operand2);
        self[Reg8::A] = result;

        self.set_flag(Flag::c, carry);
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x42,
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x00;
            RUST
            expectations: <<~RUST
              A => 0x00,
              zf => true,
            RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x22;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x0F;
            RUST
            expectations: <<~RUST
              A => 0x31,
              hf => true,
            RUST
          },
          'C' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x20;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0xF0;
            RUST
            expectations: <<~RUST
              A => 0x10,
              cf => true,
            RUST
          }
        }
      }
    },
    "ADD A, n" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A];
        let operand2 = *immediate;

        let (result, carry) = operand1.overflowing_add(operand2);
        self[Reg8::A] = result;

        self.set_flag(Flag::c, carry);
      RUST
      testing: ->(register) {
        {
          BASE => {
            extra_instruction_bytes: [0x21],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x42,
            RUST
          },
          'Z' => {
            extra_instruction_bytes: [0x0],
            expectations: <<~RUST
              A => 0x00,
              zf => true,
            RUST
          },
          'H' => {
            extra_instruction_bytes: [0x0F],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x22;
            RUST
            expectations: <<~RUST
              A => 0x31,
              hf => true,
            RUST
          },
          'C' => {
            extra_instruction_bytes: [0xF0],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x20;
            RUST
            expectations: <<~RUST
              A => 0x10,
              cf => true,
            RUST
          }
        }
      }
    },
    # We can't rely on the standard ways of computing the carry (overflowing_add()/API), because the
    # carry addition may have already set it.
    #
    "ADC A, r" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A] as u16;
        let operand2 = self[dst_register] as u16 + self.get_flag(Flag::c) as u16;

        let (result, _) = operand1.overflowing_add(operand2);
        self[Reg8::A] = result as u8;

        let carry_set = (result & 0b1_0000_0000) != 0;
        self.set_flag(Flag::c, carry_set);
      RUST
      # In some UTs, the two registers are set to the same value in order to handle `ADD A, A`.
      #
      testing: ->(register) {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg8::#{register}] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x42,
            RUST
          },
          # Using 0xFF also makes sure that the carry added is not accidentally discarded.
          #
          "#{BASE}: carry set" => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0xFF;
              cpu[Reg8::#{register}] = 0xFF;
              cpu.set_flag(Flag::c, true);
            RUST
            expectations: <<~RUST
              A => 0xFF,
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu[Reg8::#{register}] = 0;
            RUST
            expectations: <<~RUST
              A => 0x00,
              zf => true,
            RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x18;
              cpu[Reg8::#{register}] = 0x18;
            RUST
            expectations: <<~RUST
              A => 0x30,
              hf => true,
            RUST
          },
          'C' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x90;
              cpu[Reg8::#{register}] = 0x90;
            RUST
            expectations: <<~RUST
              A => 0x20,
              cf => true,
            RUST
          }
        }
      }
    },
    # See `ADC A, r` for reference notes.
    #
    "ADC A, (HL)" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A] as u16;
        let operand2 = self.internal_ram[self[Reg16::HL] as usize] as u16 + self.get_flag(Flag::c) as u16;

        let (result, _) = operand1.overflowing_add(operand2);
        self[Reg8::A] = result as u8;

        let carry_set = (result & 0b1_0000_0000) != 0;
        self.set_flag(Flag::c, carry_set);
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x42,
            RUST
          },
          "#{BASE}: carry set" => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0xFF;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0xFF;
              cpu.set_flag(Flag::c, true);
            RUST
            expectations: <<~RUST
              A => 0xFF,
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x00;
            RUST
            expectations: <<~RUST
              A => 0x00,
              zf => true,
            RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x22;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x0F;
            RUST
            expectations: <<~RUST
              A => 0x31,
              hf => true,
            RUST
          },
          'C' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x20;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0xF0;
            RUST
            expectations: <<~RUST
              A => 0x10,
              cf => true,
            RUST
          }
        }
      }
    },
    # See `ADC A, r` for reference notes.
    #
    "ADC A, n" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A] as u16;
        let operand2 = *immediate as u16 + self.get_flag(Flag::c) as u16;

        let (result, _) = operand1.overflowing_add(operand2);
        self[Reg8::A] = result as u8;

        let carry_set = (result & 0b1_0000_0000) != 0;
        self.set_flag(Flag::c, carry_set);
      RUST
      testing: ->(register) {
        {
          BASE => {
            extra_instruction_bytes: [0x21],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x42,
            RUST
          },
          "#{BASE}: carry set" => {
            extra_instruction_bytes: [0xFF],
            presets: <<~RUST,
              cpu[Reg8::A] = 0xFF;
              cpu.set_flag(Flag::c, true);
            RUST
            expectations: <<~RUST
              A => 0xFF,
            RUST
          },
          'Z' => {
            extra_instruction_bytes: [0x0],
            expectations: <<~RUST
              A => 0x00,
              zf => true,
            RUST
          },
          'H' => {
            extra_instruction_bytes: [0x0F],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x22;
            RUST
            expectations: <<~RUST
              A => 0x31,
              hf => true,
            RUST
          },
          'C' => {
            extra_instruction_bytes: [0xF0],
            presets: <<~RUST,
              cpu[Reg8::A] = 0x20;
            RUST
            expectations: <<~RUST
              A => 0x10,
              cf => true,
            RUST
          }
        }
      }
    },
    "SUB A, r" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A];
        let operand2 = self[dst_register];

        let (result, carry) = operand1.overflowing_sub(operand2);
        self[Reg8::A] = result;

        self.set_flag(Flag::c, carry);
        self.set_flag(Flag::n, true);
      RUST
      testing: ->(register) {
        # In the `SUB A, A` case, in essence, the only test case is the `Z` one.
        #
        if register == "A"
          return {
            BASE => nil,
            'Z' => {
              presets: <<~RUST,
                cpu[Reg8::#{register}] = 0x21;
              RUST
              expectations: <<~RUST
                A => 0x00,
                zf => true,
                nf => true,
              RUST
            },
            'H' => nil,
            'C' => nil,
          }
        end

        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x22;
              cpu[Reg8::#{register}] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x01,
              RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu[Reg8::#{register}] = 0x0;
            RUST
            expectations: <<~RUST
              A => 0x00,
              zf => true,
              nf => true,
              RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x20;
              cpu[Reg8::#{register}] = 0x01;
            RUST
            expectations: <<~RUST
              A => 0x1F,
              nf => true,
              hf => true,
            RUST
          },
          'C' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x70;
              cpu[Reg8::#{register}] = 0x90;
            RUST
            expectations: <<~RUST
              A => 0xE0,
              nf => true,
              cf => true,
            RUST
          }
        }
      }
    },
    "SUB A, (HL)" => {
      operation_code: <<~RUST,
        let operand1 = self[Reg8::A];
        let operand2 = self.internal_ram[self[Reg16::HL] as usize];

        let (result, carry) = operand1.overflowing_sub(operand2);
        self[Reg8::A] = result;

        self.set_flag(Flag::c, carry);
        self.set_flag(Flag::n, true);
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x42;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x21;
            RUST
            expectations: <<~RUST
              A => 0x21,
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x00;
            RUST
            expectations: <<~RUST
              A => 0x00,
              zf => true,
              nf => true,
              RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x20;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x01;
            RUST
            expectations: <<~RUST
              A => 0x1F,
              nf => true,
              hf => true,
            RUST
          },
          'C' => {
            presets: <<~RUST,
              cpu[Reg8::A] = 0x70;
              cpu[Reg16::HL] = 0xCAFE;
              cpu.internal_ram[0xCAFE] = 0x90;
            RUST
            expectations: <<~RUST
              A => 0xE0,
              nf => true,
              cf => true,
            RUST
          }
        }
      }
    },
    "INC r" => {
      operation_code: <<~RUST,
        let operand1 = self[dst_register];
        let operand2 = 1;

        let (result, _) = operand1.overflowing_add(operand2);
        self[dst_register] = result;
      RUST
      testing: ->(register) {
        {
          BASE => {
            presets: "cpu[Reg8::#{register}] = 0x21;",
            expectations: <<~RUST
              #{register} => 0x22,
            RUST
          },
          'Z' => {
            presets: "cpu[Reg8::#{register}] = 0xFF;",
            expectations: <<~RUST
              #{register} => 0x00,
              zf => true,
              hf => true,
            RUST
          },
          'H' => {
            presets: "cpu[Reg8::#{register}] = 0x1F;",
            expectations: <<~RUST
              #{register} => 0x20,
              hf => true,
            RUST
          }
        }
      }
    },
    "INC (HL)" => {
      operation_code: <<~RUST,
        let operand1 = self.internal_ram[self[Reg16::HL] as usize];
        let operand2 = 1;
        let (result, _) = operand1.overflowing_add(operand2);
        self.internal_ram[self[Reg16::HL] as usize] = result;
      RUST
      testing: ->() {
        {
          BASE => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0x21;
              cpu[Reg16::HL] = 0x0CAF;
            RUST
            expectations: <<~RUST
              mem[0x0CAF] => [0x22],
            RUST
          },
          'Z' => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0xFF;
              cpu[Reg16::HL] = 0x0CAF;
            RUST
            expectations: <<~RUST
              mem[0x0CAF] => [0x0],
              zf => true,
              hf => true,
            RUST
          },
          'H' => {
            presets: <<~RUST,
              cpu.internal_ram[0x0CAF] = 0x1F;
              cpu[Reg16::HL] = 0x0CAF;
            RUST
            expectations: <<~RUST
              mem[0x0CAF] => [0x20],
              hf => true,
            RUST
          }
        }
      }
    },
    "NOP" => {
      operation_code: "",
      testing: -> {
        {
          BASE => {
            expectations: ""
          }
        }
      }
    },
  }
end
