#!/usr/bin/python

import sys
import imageio
import numpy
import threading

def find(text):
	t=imageio.imread("t/%s.wav.png" % text).transpose().astype(numpy.int16)
	limit=float(sys.argv[3])
	prev=-1
	step=1000
	X=30.0429
	slen=t.shape[0]
	for beg in range(mi.shape[0]-slen):
		if beg < prev + 10:
			continue
		s=0
		pp=0
		for l in range(slen % step, slen, step) + [slen]:
			s += 1. * numpy.sum(numpy.absolute(mi[beg+pp:beg+l] - t[pp:l])) / t.shape[1]
#print l, s, slen, s/(l+5)
			if s / (l + 5) > limit:
				break
			pp = l
		else:
			beg += slen / 2
			print "%07.2f %02im%05.2fs %s (%s,%5.2f)" % (beg/X, int(beg/X)/60, beg/X%60, text, '*' * min(10, int(10 * (limit - s / (slen + 5)))), s / (slen+5) + 0.5)
			prev = beg
			 	


mi=imageio.imread(sys.argv[1]).transpose().astype(numpy.int16)

find(sys.argv[2])
