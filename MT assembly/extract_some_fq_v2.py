#!/usr/bin/python3
import sys
import argparse
import gzip

def extract_fq(fq1=None, fq2=None, outfq1=None, outfq2=None, size_required=None, rl_required=None, gz=True):

	size_required = size_required * (10**9)

	if fq1.endswith(".gz"):
		fh1 = gzip.open(fq1, 'rt')
		fh2 = gzip.open(fq2, 'rt')
	else:
		fh1 = open(fq1, 'rt')
		fh2 = open(fq2, 'rt')	

	if gz:
		if not outfq1.endswith(".gz"):
			outfq1 += ".gz"
		if not outfq2.endswith(".gz"):
			outfq2 += ".gz"
		fhout1 = gzip.open(outfq1, 'wt')
		fhout2 = gzip.open(outfq2, 'wt')
	else:
		fhout1 = open(outfq1, 'wt')
		fhout2 = open(outfq2, 'wt')

	size_got = 0
	for f_title in fh1:
		# fastq 1
		f_title = f_title.rstrip()
		f_seq = fh1.readline().rstrip()
		f_third = fh1.readline().rstrip()
		f_quality = fh1.readline().rstrip()


		# fastq 2
		r_title = fh2.readline().rstrip()
		r_seq = fh2.readline().rstrip()
		r_third = fh2.readline().rstrip()
		r_quality = fh2.readline().rstrip()

		f_seq_len = len(f_seq)
		r_seq_len = len(r_seq)
		if rl_required:
			if (f_seq_len<rl_required) or (r_seq_len< rl_required):
				continue
			f_seq = f_seq[0:rl_required] # the seq line
			f_quality = f_quality[0:rl_required] # the quality line
			
			r_seq = r_seq[0:rl_required] # the seq line
			r_quality = r_quality[0:rl_required] # the quality line

		# stat length
		size_got += f_seq_len
		size_got += r_seq_len

		fline = "\n".join([f_title, f_seq, f_third, f_quality])
		rline = "\n".join([r_title, r_seq, r_third, r_quality])
		print(fline, file=fhout1)
		print(rline, file=fhout2)

		if size_got >= size_required:
			break

	fh1.close()
	fh2.close()
	fhout1.close()
	fhout2.close()
	
	size_required = int(size_required)
	print("Base required:", format(size_required, ","))
	print("Base got:", format(size_got, ","))

	return size_got


def main():
	parser = argparse.ArgumentParser(description="Extract some fastq reads from the beginning of the files. Author: mengguanliang@genomics.cn")

	parser.add_argument("-fq1", metavar="<str>", help="input fastq 1 file")

	parser.add_argument("-fq2", metavar="<str>", help="input fastq 2 file")

	parser.add_argument("-outfq1", metavar="<str>", help="output fastq 1 file")

	parser.add_argument("-outfq2", metavar="<str>", help="output fastq 2 file")

	parser.add_argument("-size_required", type=float, default=3, 
		metavar="<float>", help="size required in Gigabase. [%(default)s]")

	parser.add_argument("-rl", type=int, metavar="<int>", default='None', 
		help="read length required. discard the smaller ones, and cut the longer ones to this length [%(default)s]")

	parser.add_argument("-gz", action="store_true", default=False,
		help="gzip output. [%(default)s]")

	if len(sys.argv) == 1:
		parser.print_help()
		sys.exit()
	else:
		args = parser.parse_args()

	extract_fq(fq1=args.fq1, fq2=args.fq2, outfq1=args.outfq1, 
		outfq2=args.outfq2, size_required=args.size_required, 
		rl_required=args.rl, gz=args.gz)

	return 0

if __name__ == "__main__":
	main()
