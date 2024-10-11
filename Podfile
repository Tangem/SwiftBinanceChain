source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def common
	pod 'BinanceChain', :path => '.'
	pod 'BinanceChain/Test', :path => '.'
	pod 'SwiftProtobuf', :inhibit_warnings => true
end

target "Mobile" do
	platform :ios, '15.0'
	common
end

target "Desktop" do
	platform :macos, '12.0'
	common
end
