from constants import Constants


class Pacman:
    # Draw the Right Facing PacMan
    def __init__(self):
        pass

    @staticmethod
    def draw_pacman_right(outfile):
        print "Drawing Pacman Right..."
        # First Line
        for x in range(0, 8):
            if x < 2 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Second Line
        for x in range(0, 8):
            if x == 0 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Third Line
        for x in range(0, 8):
            if x > 4:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Forth Line
        for x in range(0, 8):
            if x > 3:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Fifth Line
        for x in range(0, 8):
            if x > 3:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Sixth Line
        for x in range(0, 8):
            if x > 4:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Seventh Line
        for x in range(0, 8):
            if x == 0 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Eighth Line
        for x in range(0, 8):
            if x < 2 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

    # Draw the Left Facing PacMan
    @staticmethod
    def draw_pacman_left(outfile):
        print "Drawing Pacman Left..."
        # First Line
        for x in range(0, 8):
            if x == 0 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Second Line
        for x in range(0, 8):
            if x < 2 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Third Line
        for x in range(0, 8):
            if x < 3:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Forth Line
        for x in range(0, 8):
            if x < 4:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Fifth Line
        for x in range(0, 8):
            if x < 4:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Sixth Line
        for x in range(0, 8):
            if x < 3:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Seventh Line
        for x in range(0, 8):
            if x < 2 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Eighth Line
        for x in range(0, 8):
            if x == 0 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

    # Draw the Down Facing PacMan
    @staticmethod
    def draw_pacman_down(outfile):
        print "Drawing Pacman Down..."
        # First Line
        for x in range(0, 8):
            if x < 2 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Second Line
        for x in range(0, 8):
            if x == 0 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Third Line
        for x in range(0, 8):
            outfile.write(Constants.color['yellow'])

        # Forth Line
        for x in range(0, 8):
            outfile.write(Constants.color['yellow'])

        # Fifth Line
        for x in range(0, 8):
            if x == 3 or x == 4:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Sixth Line
        for x in range(0, 8):
            if x < 1 or x > 6:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Seventh Line
        for x in range(0, 8):
            if x > 0 or x < 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Eighth Line
        for x in range(0, 8):
            outfile.write(Constants.color['black'])

    # Draw the Up Facing PacMan
    @staticmethod
    def draw_pacman_up(outfile):
        print "Drawing Pacman Up..."
        # First Line
        for x in range(0, 8):
            outfile.write(Constants.color['black'])

        # Second Line
        for x in range(0, 8):
            if x > 0 or x < 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Third Line
        for x in range(0, 8):
            if x < 1 or x > 6:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Forth Line
        for x in range(0, 8):
            if x == 3 or x == 4:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Fifth Line
        for x in range(0, 8):
            outfile.write(Constants.color['yellow'])

        # Sixth Line
        for x in range(0, 8):
            outfile.write(Constants.color['yellow'])

        # Seventh Line
        for x in range(0, 8):
            if x == 0 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])

        # Eighth Line
        for x in range(0, 8):
            if x < 2 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(Constants.color['yellow'])


class Ghost:
    def __init__(self):
        pass

    """
    outfile = the output file to write the data to
    ghost_color = the hex value of the color of the ghost
    """
    @staticmethod
    def create(outfile, ghost_color):
        print "Drawing a Ghost..."
        # First Line
        for x in range(0, 8):
            if x < 2 or x > 5:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(ghost_color)

        # Second Line
        for x in range(0, 8):
            if x == 0 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(ghost_color)

        # Third and Forth Line
        for y in range(0, 2):
            for x in range(0, 8):
                if x == 2 or x == 5:
                    outfile.write(Constants.color['white'])
                else:
                    outfile.write(ghost_color)

        # Fifth, Sixth, Seventh Line
        for y in range(0, 3):
            for x in range(0, 8):
                outfile.write(ghost_color)

        # Eighth Line
        for x in range(0, 8):
            if x == 0 or x == 2 or x == 5 or x == 7:
                outfile.write(Constants.color['black'])
            else:
                outfile.write(ghost_color)


class Dot:

    def __init__(self):
        pass

    @staticmethod
    def create(outfile, size):
        if size == "small":
            print "Drawing Small Dot..."
            # First, Second, Third Lines
            for y in range(0, 3):
                for x in range(0, 8):
                    outfile.write(Constants.color['black'])

            # Forth and Fifth Lines
            for y in range(0, 2):
                for x in range(0, 8):
                    if x != 3 or x != 4:
                        outfile.write(Constants.color['black'])
                    else:
                        outfile.write(Constants.color['yellow'])

            # Sixth, Seventh, Eighth Lines
            for y in range(0, 3):
                for x in range(0, 8):
                    outfile.write(Constants.color['black'])

        elif size == "large":
            print "Drawing Large Dot..."
            # First and Second Lines
            for y in range(0, 2):
                for x in range(0, 8):
                    outfile.write(Constants.color['black'])

            # Third, Forth, Fifth, Sixth Lines
            for y in range(0, 4):
                for x in range(0, 8):
                    if x < 2 or x > 5:
                        outfile.write(Constants.color['black'])
                    else:
                        outfile.write(Constants.color['yellow'])

            # Seventh and Eight Lines
            for y in range(0, 2):
                for x in range(0, 8):
                    outfile.write(Constants.color['black'])