Pod::Spec.new do |s|
    s.name  = 'FastPdfKit'
    s.version = '4.5'
    s.platform = :ios, '6.0'
    s.homepage = 'http://www.fastpdfkit.com'
    s.authors = 'MobFarm'
    s.summary = 'PDF library for iOS'
    s.source = {:git => 'raspo:/git/FastPdfKit.git', :tag => s.version.to_s}
    s.requires_arc = true
    s.preferred_dependency = 'Reader'

    s.subspec 'Reader' do |r|
        r.source_files = 'Reader/**/*.{h,m}'
        r.resources = 'Reader/**/*.xib'
        r.dependency 'FastPdfKit/Core'
    end
    
    s.subspec 'Core' do |c|
        c.source_files = 'Core/**/*.{h,m}'
        c.vendored_libraries = 'Core/libFastPdfKit.a'
    end
end
