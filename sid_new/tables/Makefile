
all:	tableconvert sid_6581_ps.out sid_6581_p_t.out sid_8580_p_t.out sid_8580_st_ps_pst.out

clean:
	-rm *.out
	-rm tableconvert

%.out: %.txt
	./tableconvert <$+ >$@

tableconvert: tableconvert.c
	gcc tableconvert.c -o tableconvert

