class Constants:
    def __init__(self):
        pass

    color = dict(
        red='ff0000,\n',
        green='008000,\n',
        blue='0000ff,\n',
        light_blue='add8e6,\n',
        white='ffffff,\n',
        black='000000,\n',
        yellow='ffff00,\n',
        orange='ffa500, \n',
        purple='800080,\n',
        end='000000;'
        )

    registers = dict(
        R0='00000',
        R1='00001',
        R2='00010',
        R3='00011',
        R4='00100',
        R5='00101',
        R6='00110',
        R7='00111',
        R8='01000',
        R9='01001',
        R10='01010',
        R11='01011',
        R12='01100',
        R13='01101',
        R14='01110',
        R15='01111',
        R16='10000',
        R17='10001',
        R18='10010',
        R19='10011',
        R20='10100',
        R21='10101',
        R22='10110',
        R23='10111',
        R24='11000',
        R25='11001',
        R26='11010',
        R27='11011',
        R28='11100',
        R29='11101',
        R30='11110',
        R31='11111'
    )

    attributes = dict(
        HTH='0000',
        SCR='0001',
        LIV='0010',
        SPD='0011',
        DIF='0100',
        DAM='0101',
        PLY='0110',
        IMG='0111',
        XCRD='1000',
        YCRD='1001'
    )

    actions = dict(
        UP='0000',
        DO='0001',
        LFT='0010',
        RGH='0011',
        DES='0100',
        CRT='0101',
        RST='0110',
        ATK='0111'
    )

    conditions = dict(
        NEQ='000',
        EQ='001',
        GT='010',
        LT='011',
        GTE='100',
        LTE='101',
        OVFL='110',
        UNCON='111'
    )

    hex_digits = {
        '0': "0000",
        '1': "0001",
        '2': "0010",
        '3': "0011",
        '4': "0100",
        '5': "0101",
        '6': "0110",
        '7': "0111",
        '8': "1000",
        '9': "1001",
        'A': "1010",
        'a': "1010",
        'B': "1011",
        'b': "1011",
        'C': "1100",
        'c': "1100",
        'D': "1101",
        'd': "1101",
        'E': "1110",
        'e': "1110",
        'F': "1111",
        'f': "1111"
    }

    error_msg = "ERROR IN LINE"