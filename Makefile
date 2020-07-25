
clean:
		rm -rf .build

xcode:
		swift package generate-xcodeproj

edit:
		open -a Xcode Swarm.xcodeproj
