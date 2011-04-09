all:
	xcodebuild
run:
	open build/Release/ExpandHelpApp.app
test:
	macruby Tests/run_suite.rb
