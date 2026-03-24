local M = {}

function M.insert_template()
  vim.cmd("silent! %d")

  local template = {
    "#include<bits/stdc++.h>",
    "#define int long long",
    "#define endl '\\n'",
    "using namespace std;",
    "const int N = 1e5 + 10;",
    "const int mod = 998244353;",
    "",
    "void gugugaga() {",
    "  ",
    "}",
    "",
    "signed main() {",
    "  ios::sync_with_stdio(false);",
    "  cin.tie(0); cout.tie(0);",
    "  ",
    "  int _ = 1;",
    "  // cin >> _;",
    "  while (_--) gugugaga();",
    "  ",
    "  return 0;",
    "}",
  }

  vim.api.nvim_buf_set_lines(0, 0, -1, false, template)

  -- 光标定位到 solve 内
  vim.api.nvim_win_set_cursor(0, { 9, 4 })
end

return M
