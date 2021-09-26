import sys
read_file=open(sys.argv[1],"r")
chans = read_file.readline()

def chans_to_freqs(chans, flo, bw, nchans):
    out = []
    chbw = bw/nchans
    for pair in chans.split(","):
        s = list(map(float, pair.split(":")))
        if len(s) == 1:
            chan = s[0]
            out.append("{}:{}".format(flo + chbw * (chan-0.5), flo + chbw * (chan+1.5)))
        elif len(s) == 2:
            chan0, chan1 = s
            out.append("{}:{}".format(flo + chbw * (chan0-0.5), flo + chbw * (chan1+0.5)))
        else:
            print("Unknown format: {}".format(pair))
            continue
    return ",".join(out)

mhz_list = chans_to_freqs(chans, 855.9, 856, 2048)
print(mhz_list)