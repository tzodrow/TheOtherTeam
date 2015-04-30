import warnings
from helpers import Helper
from constants import Constants

__author__ = 'tzodrow'


def check_valid(dictionary, value, arg_num, line_num):
    if value in dictionary:
        return True
    else:
        warnings.warn("Invalid entry at line " + str(line_num) + " for argument " + str(arg_num), SyntaxWarning)
        return False


class Function:

    labels = dict()

    def __init__(self):
        pass

    @staticmethod
    def add(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '00000' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Constants.registers[args[2]] + Helper.pad("0", 12)
        else:
            return Constants.error_msg

    @staticmethod
    def addi(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '00001' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def sub(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '00010' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Constants.registers[args[2]] + Helper.pad("0", 12)
        else:
            return Constants.error_msg

    @staticmethod
    def subi(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '00011' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def lw(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '00100' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def sw(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '00101' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def mov(args, line_num):
        if len(args) != 2:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num):
            return '00110' + Constants.registers[args[0]] + Constants.registers[args[1]] + Helper.pad("0", 17)
        else:
            return Constants.error_msg

    @staticmethod
    def movi(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '00111' + Constants.registers[args[1]] + Helper.pad(bin(int(args[0]))[2:], 2) \
                   + Helper.pad("0", 12) + Helper.pad(bin(int(args[2]))[2:], 8)
        else:
            return Constants.error_msg

    @staticmethod
    def andi(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '01000' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Constants.registers[args[2]] + Helper.pad("0", 12)
        else:
            return Constants.error_msg

    @staticmethod
    def ori(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '01001' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Constants.registers[args[2]] + Helper.pad("0", 12)
        else:
            return Constants.error_msg

    @staticmethod
    def nor(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '01010' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Constants.registers[args[2]] + Helper.pad("0", 12)
        else:
            return Constants.error_msg

    @staticmethod
    def sll(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '01011' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def srl(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '01100' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def sra(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num) \
                and check_valid(Constants.registers, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '01101' + Constants.registers[args[0]] + Constants.registers[args[1]] \
                   + Helper.pad(bin(int(args[2]))[2:], 17)
        else:
            return Constants.error_msg

    @staticmethod
    def b(args, line_num):
        if len(args) != 2:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.conditions, args[0], 1, line_num) \
                and check_valid(Function.labels, args[1], 2, line_num):
            return '01110' + Constants.conditions[args[0]] + Helper.pad("0", 2) \
                   + Helper.pad(bin(int(Function.labels[args[1]]))[2:], 22)
        else:
            return Constants.error_msg

    @staticmethod
    def j():
        print 'NO IMPLEMENTED'

    @staticmethod
    def jr(args, line_num):
        if len(args) != 1:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 1, line_num):
            return '10000' + Constants.registers[args[0]] + Helper.pad("0", 22)
        else:
            return Constants.error_msg

    @staticmethod
    def jal(args, line_num):
        if len(args) != 1:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Function.labels, args[0], 1, line_num):
            return '10001' + Helper.pad(bin(Function.labels[args[0]])[2:], 27)
        else:
            return Constants.error_msg

    @staticmethod
    def act(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.actions, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '10010' + Constants.actions[args[1]] + Helper.pad(bin(int(args[0]))[2:], 8) \
                   + Constants.registers[args[2]] + Helper.pad("0", 10)
        else:
            return Constants.error_msg

    @staticmethod
    def acti(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.actions, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '10010' + Constants.actions[args[1]] + Helper.pad(bin(int(args[0]))[2:], 8) \
                   + Helper.pad(bin(int(args[2]))[2:], 14) + "1"
        else:
            return Constants.error_msg

    @staticmethod
    def ld(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.attributes, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '10011' + Constants.attributes[args[1]] + Helper.pad(bin(int(args[0]))[2:], 8) \
                   + Constants.registers[args[2]] + Helper.pad("0", 10)
        else:
            return Constants.error_msg

    @staticmethod
    def ldi(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.attributes, args[1], 2, line_num) \
                and isinstance(int(args[2]), int):
            return '10011' + Constants.attributes[args[1]] + Helper.pad(bin(int(args[0]))[2:], 8) \
                   + Helper.pad(bin(int(args[2]))[2:], 14) + "1"
        else:
            return Constants.error_msg

    @staticmethod
    def rdi(args, line_num):
        if len(args) != 3:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.attributes, args[1], 2, line_num) \
                and check_valid(Constants.registers, args[2], 3, line_num):
            return '10100' + Constants.attributes[args[1]] + Helper.pad(bin(int(args[0]))[2:], 8) \
                   + Constants.registers[args[2]] + Helper.pad("0", 10)
        else:
            return Constants.error_msg

    @staticmethod
    def mapi(args, line_num):
        if len(args) != 1:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int):
            return '10101' + Helper.pad("0", 12) + Helper.pad(bin(int(args[0]))[2:], 14) + "1"
        else:
            return Constants.error_msg

    @staticmethod
    def cord(args, line_num):
        if len(args) != 2:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int) and check_valid(Constants.registers, args[1], 2, line_num):
            return '10110' + Helper.pad("0", 4) + Helper.pad(bin(int(args[0]))[2:], 8) \
                   + Constants.registers[args[1]] + Helper.pad("0", 10)
        else:
            return Constants.error_msg

    @staticmethod
    def key(args, line_num):
        if len(args) != 1:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if check_valid(Constants.registers, args[0], 2, line_num):
            return '10111' + Constants.registers[args[0]] + Helper.pad("0", 22)
        else:
            return Constants.error_msg

    @staticmethod
    def tm(args, line_num):
        if len(args) != 1:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        if isinstance(int(args[0]), int):
            return '11000' + Helper.pad("0", 12) + Helper.pad(bin(int(args[0]))[2:], 14) + "1"
        else:
            return Constants.error_msg

    @staticmethod
    def halt(args, line_num):
        if len(args) != 0:
            warnings.warn("Invalid Number of arguments at line " + str(line_num), SyntaxWarning)
            return Constants.error_msg
        else:
            return '11111' + Helper.pad("0", 27)

    @staticmethod
    def process(line, outfile, line_num):
        args = line.split()
        if not args[0].upper() in opcodes:
            if args[0].upper() in Function.labels:
                args.pop(0)
            else:
                warnings.warn("Label (" + args[0] + ") Repeated at line " + str(line_num), SyntaxWarning)

        opcode = args.pop(0).upper()
        if opcode in opcodes:
            instr = opcodes[opcode](args, line_num)
            if instr != Constants.error_msg:
                print instr
                outfile.write("%s,\n" % instr)
            else:
                print Constants.error_msg + ": " + line
                outfile.write("%s,\n" % Constants.error_msg + ": " + line)
        else:
            warnings.warn("Opcode(" + opcode + ") does not exist at line " + str(line_num), SyntaxWarning)

    @staticmethod
    def is_comment(line):
        args = line.split()
        if args[0] == '#':
            return True
        else:
            return False

    @staticmethod
    def find_labels(line, line_num):
        args = line.split()
        label = args[0].upper()
        if not (label in opcodes):
            if label in Function.labels:
                warnings.warn("Label Repeated at line " + str(line_num), SyntaxWarning)
                return False
            else:
                Function.labels[label] = line_num
                return True
        else:
            return True


opcodes = dict(
    ADD=Function.add,
    ADDI=Function.addi,
    SUB=Function.sub,
    SUBI=Function.subi,
    LW=Function.lw,
    SW=Function.sw,
    MOV=Function.mov,
    MOVI=Function.movi,
    AND=Function.andi,
    OR=Function.ori,
    NOR=Function.nor,
    SLL=Function.sll,
    SRL=Function.srl,
    SRA=Function.sra,
    B=Function.b,
    J=Function.j,
    JR=Function.jr,
    JAL=Function.jal,
    ACT=Function.act,
    ACTI=Function.acti,
    LD=Function.ld,
    LDI=Function.ldi,
    RD=Function.rdi,
    MAP=Function.mapi,
    CORD=Function.cord,
    KEY=Function.key,
    TM=Function.tm,
    HALT=Function.halt
)