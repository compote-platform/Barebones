
clean:
	rm -rf .build

edit:
	open -a Xcode .

tags:
	git push origin master --tags
