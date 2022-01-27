fa <- readDNAStringSet("tmp4genomictools/Danio_rerio.GRCz11.cdna.all.fa.gz")
sel <- c("cox6b2", "perp", "psmb1", "ankhd1", "pno1", "rasip1", "adssl", "plek",
         "impdh1b", "stx5al", "hapln1a", "eif4ebp3", "rap1b", "sbk3",
         "zgc:110540", "wdr92", "lepb", "nat14", "prok2", "ca4a", "bag2")
ids <- lapply(sel, function(.ele) grepl(paste0("gene_symbol:", .ele, " "), names(fa)))
ids <- do.call(cbind, ids)
ids <- rowSums(ids)
sum(ids)
length(sel)
ids <- which(ids==1)
fas <- fa[ids]
n <- sub("^.*?gene_symbol:(.*?) .*$", "\\1", names(fas))
n <- unique(n)
sel[!sel %in% n]

writeXStringSet(fas, filepath = "inst/extdata/Danio_rerio.GRCz11.cdna.toy.fa")
system("gzip inst/extdata/Danio_rerio.GRCz11.cdna.toy.fa")

fa <- readDNAStringSet("tmp4genomictools/Danio_rerio.GRCz11.dna.primary_assembly.fa.gz")
sel <- c(4, 13, 16, 21)
ids <- grepl(paste0("^(", paste(sel, collapse="|"), ")"), names(fa))
names(fa)[ids]
fas <- fa[ids]
fas <- subseq(fas, 1, 30e6)
writeXStringSet(fas, filepath = "inst/extdata/Danio_rerio.GRCz11.dna.toy.fa")
system("gzip inst/extdata/Danio_rerio.GRCz11.dna.toy.fa")
