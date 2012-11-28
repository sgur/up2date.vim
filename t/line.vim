call vspec#hint({'scope': 'up2date#line#scope()', 'sid': 'up2date#line#sid()'})

describe 'Option parsing module'
  it 'should extract url'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git @abc32f').url
          \ ==# 'git://github.com/Shougo/neocomplcache.git'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git').url
          \ ==# 'git://github.com/Shougo/neocomplcache.git'
  end

  it 'should detect scm revision'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git @abc32f').revision ==# 'abc32f'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git').revision ==# ''
  end

  it 'should detect scm branch'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git +develop').branch ==# 'develop'
    Expect Call('s:parse_options', 'git@github.com:Shougo/neocomplcache.git +view').branch ==# 'view'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git').branch ==# ''
  end

  it 'should detect target_dir'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git +develop /neocomplcache').target ==# 'neocomplcache'
    Expect Call('s:parse_options', 'git@github.com:Shougo/neocomplcache.git +view /neocom').target ==# 'neocom'
    Expect Call('s:parse_options', 'git://github.com/Shougo/neocomplcache.git /neocon').target ==# 'neocon'
  end

  it 'should detect ftbundle'
  Expect Call('s:parse_options', 'https://github.com/Rip-Rip/clang_complete.git #cpp').filetype ==# 'cpp'
  Expect Call('s:parse_options', 'https://github.com/Rip-Rip/clang_complete.git').filetype ==# ''
  end

  it 'should detect scm type'
    Expect Call('s:scm_from_line', 'git://github.com/Shougo/neocomplcache.git').scm
          \ ==# 'git'
    Expect Call('s:scm_from_line', 'https://github.com/Shougo/neocomplcache.git').dir
          \ ==# 'neocomplcache'
    Expect Call('s:scm_from_line', 'https://github.com/Shougo/neocomplcache').scm
          \ ==# 'git'
    Expect Call('s:scm_from_line', 'git@github.com:Shougo/neocomplcache.git').scm
          \ ==# 'git'
    Expect Call('s:scm_from_line', 'https://github.com/Shougo/neocomplcache.git').scm
          \ ==# 'git'
    Expect Call('s:scm_from_line', 'https://bitbucket.org/sjl/badwolf.git').scm
          \ ==# 'git'
    Expect Call('s:scm_from_line', 'git@bitbucket.org:badwolf/badwolf.git').scm
          \ ==# 'git'
    Expect Call('s:scm_from_line', 'https://bitbucket.org/sjl/badwolf').scm
          \ ==# 'mercurial'
    Expect Call('s:scm_from_line', 'ssh://bitbucket.org/sjl/badwolf').scm
          \ ==# 'mercurial'
    Expect Call('s:scm_from_line', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -git').scm
          \ ==# 'unknown'
    Expect Call('s:scm_from_line', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -subversion').scm
          \ ==# 'unknown'
    Expect Call('s:scm_from_line', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/').scm
          \ ==# 'unknown'
    Expect Call('s:parse_options', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -git').scm
          \ ==# 'git'
    Expect Call('s:parse_options', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/ -subversion').scm
          \ ==# 'subversion'
    Expect Call('s:parse_options', 'http://vim-soko.googlecode.com/svn/trunk/autofmt/').scm
          \ ==# ''
  end

end

describe 'Line parsing module'
  it 'should extract "BUNDLE: .\+" line'
    Expect Call('up2date#line#extract', 'abcdefgh') ==# ''
    Expect Call('up2date#line#extract', 'abc" defgh') ==# ''
    Expect Call('up2date#line#extract', 'ab"c"de"fgh') ==# ''
    Expect Call('up2date#line#extract', 'a"bcdefgh') ==# ''
  nnoremap <C-p><C-p> :<C-u>CtrlPDir
    Expect Call('up2date#line#extract', '" abcdefgh') ==# ''
    Expect Call('up2date#line#extract', '"abcdefgh') ==# ''
    Expect Call('up2date#line#extract', 'BUNDLE:abcdefgh') ==# 'abcdefgh'
    Expect Call('up2date#line#extract', 'BUNDLE: abcdefgh') ==# 'abcdefgh'
    Expect Call('up2date#line#extract', '" BUNDLE: abcdefgh') ==# 'abcdefgh'
  end

  it 'should parse valid line'
    let opt = Call('up2date#line#parse', 'git://github.com/Shougo/neocomplcache.git @abc32f')
    Expect opt.scm ==# 'git'
    Expect opt.url ==# 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision ==# 'abc32f'
    Expect opt.branch ==# ''
    Expect opt.target ==# 'neocomplcache'
    let opt = Call('up2date#line#parse', 'git://github.com/Shougo/neocomplcache.git +develop /neocomplcache')
    Expect opt.scm ==# 'git'
    Expect opt.url ==# 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision ==# ''
    Expect opt.branch ==# 'develop'
    Expect opt.target ==# 'neocomplcache'
    let opt = Call('up2date#line#parse', 'git://github.com/Shougo/neocomplcache.git +develop')
    Expect opt.scm ==# 'git'
    Expect opt.url ==# 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision ==# ''
    Expect opt.branch ==# 'develop'
    Expect opt.target ==# 'neocomplcache'
    let opt = Call('up2date#line#parse', 'git://github.com/Shougo/neocomplcache.git')
    Expect opt.scm ==# 'git'
    Expect opt.url ==# 'git://github.com/Shougo/neocomplcache.git'
    Expect opt.revision ==# ''
    Expect opt.branch ==# ''
    Expect opt.target ==# 'neocomplcache'
    let opt = Call('up2date#line#parse', 'https://github.com/Rip-Rip/clang_complete.git #cpp')
    Expect opt.scm ==# 'git'
    Expect opt.url ==# 'https://github.com/Rip-Rip/clang_complete.git'
    Expect opt.revision ==# ''
    Expect opt.branch ==# ''
    Expect opt.target ==# 'clang_complete'
    Expect opt.filetype ==# 'cpp'
  end
end

