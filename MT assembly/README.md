**mitochondrial genome assembly**
  1. Extract some fastq reads from the beginning of the files.
    
    >python3 extract_some_fq_v2.py -fq1 160328_I633_FCC837EACXX_L3_CHKPEI85216020105_1.fq.gz.clean.dup.clean.gz -fq2 160328_I633_FCC837EACXX_L3_CHKPEI85216020105_2.fq.gz.clean.dup.clean.gz -outfq1 160328_I633_FCC837EACXX_L3_CHKPEI85216020105_1.fq -outfq2 160328_I633_FCC837EACXX_L3_CHKPEI85216020105_2.fq -rl 130 -size_required 1.43
    
  2. assemble the whole mitochondrial genome
    
    >python3 MitoZ.py all --thread_number 8 --soaptrans_thread_number 8 --clade Chordata --genetic_code 2  --outprefix Crypturellus_undulatus --insert_size 800 --fastq_read_length 150 --fastq1 Crypturellus_undulatus_1.fq.gz --fastq2 Crypturellus_undulatus_2.fq.gz --filter_taxa_method 1  --find_missing_mito_method 2 --annotation
    
    
