import sys
read_file=open(sys.argv[1],"r")
chans = read_file.readline()
middle = float(sys.argv[2])
bandwidth = float(sys.argv[3])
bottom= middle - bandwidth/2
nchan = int(sys.argv[4])

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

mhz_list = chans_to_freqs(chans, bottom, bandwidth, nchan)
print(mhz_list)