call vspec#hint({'scope': 'up2date#default#scope()', 'sid': 'up2date#default#sid()'})


describe 'Default source path'
  it 'should select ~/[._]vimrc for ''~/'''
    Expect expand(Call('s:default_source_path', '~')) =~# '[._]vimrc'
    Expect expand(Call('s:default_source_path', '~/')) =~# '[._]vimrc'
  end

  it 'should select no path for unexistence directory'
    Expect expand(Call('s:default_source_path', '/foo/bar/')) ==# ''
    Expect expand(Call('s:default_source_path', '~/..')) ==# ''
  end
end


