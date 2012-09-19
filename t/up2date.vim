call vspec#hint({'scope': 'up2date#scope()', 'sid': 'up2date#sid()'})


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


describe 'Selecting source'
  it 'should select specified path'
    call writefile([], '.vimrc')
    Expect expand(Call('s:select_source', '.vimrc')) ==# expand('.vimrc')
    call delete('.vimrc')
  end
  it 'shouldn''t select unexistence path'
    Expect expand(Call('s:select_source', 'foo_bar')) ==# ''
  end
  it 'should select default path'
    if filereadable('~/.vimrc')
      Expect expand(Call('s:select_source', '')) ==# expand('~/.vimrc')
      let g:up2date_source_path = '~/.vimrc'
      Expect expand(Call('s:select_source', '')) ==# expand('~/.vimrc')
    elseif filereadable('~/_vimrc')
      Expect expand(Call('s:select_source', '')) ==# expand('~/_vimrc')
      let g:up2date_source_path = '~/.vimrc'
      Expect expand(Call('s:select_source', '')) ==# expand('~/.vimrc')
    endif
  end
end
