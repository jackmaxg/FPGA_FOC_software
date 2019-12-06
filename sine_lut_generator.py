import getopt, sys
import numpy as np


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "f:w:d:", ["filename=","width=","depth="])
    except getopt.GetoptError:
        print('sine_lut_generator.py -f <filename> -w <table index width> -d <table index depth>')
        sys.exit(2)

    filename = 'lut.txt'
    depth = 16
    width = 10
    for opt, arg in opts:
        if opt in ('-f', '--filename'):
            filename = arg
        elif opt in ('-w', '--width'):
            width = int(arg)
        elif opt in ('-d', '--depth'):
            depth = int(arg)

    sines = np.sin(np.linspace(0, 2*np.pi, 2**width, endpoint=False))*(2**(depth-1)-1)
    sines = sines.astype(int)
    sines[sines < 0] = 2**depth + sines[sines < 0]
    
    with open(filename, 'w') as fout:
        for i in sines:
            fout.write('%x\n' % i)


if __name__ == "__main__":
    main(sys.argv[1:])
