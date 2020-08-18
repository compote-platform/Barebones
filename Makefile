
clean:
	rm -rf .build

xcode:
	swift package generate-xcodeproj

edit:
	open -a Xcode *.xcodeproj

tags:
	git push origin master --tags
