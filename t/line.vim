call vspec#hint({'scope': 'up2date#line#scope()', 'sid': 'up2date#line#sid()'})

describe 'autoload/up2date/line.vim'
  it 'should extract "BUNDLE:" line'
    Expect Call('s:extract', 'abcdefgh') == ''
    Expect Call('s:extract', 'abc" defgh') == ''
    Expect Call('s:extract', 'ab"c"de"fgh') == ''
    Expect Call('s:extract', 'a"bcdefgh') == ''
    Expect Call('s:extract', '" abcdefgh') == ''
    Expect Call('s:extract', '"abcdefgh') == ''
    Expect Call('s:extract', 'BUNDLE:abcdefgh') == 'abcdefgh'
    Expect Call('s:extract', 'BUNDLE: abcdefgh') == 'abcdefgh'
    Expect Call('s:extract', '" BUNDLE: abcdefgh') == 'abcdefgh'
  end

  it 'should extract url'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git @abc32f').url
          \ == 'git://github.com/Shougo/neocomplcache.git'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git').url
          \ == 'git://github.com/Shougo/neocomplcache.git'
  end

  it 'should detect scm revision'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git @abc32f').revision == 'abc32f'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git').revision == ''
  end

  it 'should detect scm branch'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git +develop').branch == 'develop'
    Expect Call('s:parse_options', 'git@github.com:Shougo/neocomplcache.git +view').branch == 'view'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git').branch == ''
  end

  it 'should detect target_dir'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git +develop /neocomplcache').target == 'neocomplcache'
    Expect Call('s:parse_options', 'git@github.com:Shougo/neocomplcache.git +view /neocom').target == 'neocom'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git /neocon').target == 'neocon'
  end

  it 'should detect scm type'
    Expect Call('s:scm_from_line', 'git://github.com/Shougo/neocomplcache.git').scm
          \ == 'git'
    Expect Call('s:scm_from_line', 'git@github.com:Shougo/neocomplcache.git').scm
          \ == 'git'
    Expect Call('s:scm_from_line', 'https://github.com/Shougo/neocomplcache.git').scm
          \ == 'git'
    Expect Call('s:scm_from_line', 'https://bitbucket.org/sjl/badwolf.git').scm
          \ == 'git'
    Expect Call('s:scm_from_line', 'git@bitbucket.org:badwolf/badwolf.git').scm
          \ == 'git'
    Expect Call('s:scm_from_line', 'https://bitbucket.org/sjl/badwolf').scm
          \ == 'mercurial'
    Expect Call('s:scm_from_line', 'ssh://bitbucket.org/sjl/badwolf').scm
          \ == 'mercurial'
    Expect Call('s:scm_from_line', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -git').scm
          \ == 'unknown'
    Expect Call('s:scm_from_line', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -subversion').scm
          \ == 'unknown'
    Expect Call('s:scm_from_line', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/').scm
          \ == 'unknown'
    Expect Call('s:parse_options', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -git').scm
          \ == 'git'
    Expect Call('s:parse_options', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -subversion').scm
          \ == 'subversion'
    Expect Call('s:parse_options', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/').scm
          \ == ''
  end

  it 'should parse line'
    let opt = Call('up2date#line#parse', 'BUNDLE: git://github.com/Shougo/neocomplcache.git @abc32f')
    Expect opt.scm == 'git'
    Expect opt.url == 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision == 'abc32f'
    Expect opt.branch == ''
    Expect opt.target == 'neocomplcache'
    let opt = Call('up2date#line#parse', 'BUNDLE: git://github.com/Shougo/neocomplcache.git +develop /neocomplcache')
    Expect opt.scm == 'git'
    Expect opt.url == 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision == ''
    Expect opt.branch == 'develop'
    Expect opt.target == 'neocomplcache'
    let opt = Call('up2date#line#parse', '" BUNDLE:git://github.com/Shougo/neocomplcache.git +develop')
    Expect opt.scm == 'git'
    Expect opt.url == 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision == ''
    Expect opt.branch == 'develop'
    Expect opt.target == 'neocomplcache'
    let opt = Call('up2date#line#parse', '"BUNDLE: git://github.com/Shougo/neocomplcache.git')
    Expect opt.scm == 'git'
    Expect opt.url == 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision == ''
    Expect opt.branch == ''
    Expect opt.target == 'neocomplcache'
  end
end

