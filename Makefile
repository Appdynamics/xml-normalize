OUTPUT= tests/test*.xml.normal

test:
	@ shopt -s nullglob; for test in tests/test*.xml ; do \
		echo testing $$test ; \
			./xml-normal.sh $$test $$test.normal ; \
		if ! cmp -s $$test.normal $$test.check ; then \
			echo $$test failed ; \
		fi ; \
	done

clean:
	rm -f $(OUTPUT)
