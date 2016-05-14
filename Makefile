all:
	xcodebuild
run:
	open build/Release/ExpandHelpApp.app
test:
	macruby Tests/run_suite.rb
push:
	git push -u origin master
	git push -u github master
