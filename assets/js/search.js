// 项目层覆盖：用 Pagefind UI 替换 Blowfish 内建 Fuse 搜索
// 保留 Blowfish 顶部 search 按钮的 show/hide 模态触发逻辑
// PagefindUI 懒加载（首次打开模态时初始化），避免影响首屏

var showButton = document.getElementById("search-button");
var showButtonMobile = document.getElementById("search-button-mobile");
var hideButton = document.getElementById("close-search-button");
var wrapper = document.getElementById("search-wrapper");
var modal = document.getElementById("search-modal");

var searchVisible = false;
var pagefindInitialized = false;

function ensurePagefindUI() {
  if (pagefindInitialized) return Promise.resolve();
  pagefindInitialized = true;
  return import("/pagefind/pagefind-ui.js").then(function (mod) {
    new mod.PagefindUI({
      element: "#search",
      showSubResults: true,
      showImages: false,
      resetStyles: false,
      translations: {
        placeholder: "搜索文章…",
        clear_search: "清空",
        load_more: "加载更多结果",
        search_label: "搜索本站",
        filters_label: "过滤",
        zero_results: "没有找到与「[SEARCH_TERM]」相关的内容",
        many_results: "找到 [COUNT] 条与「[SEARCH_TERM]」相关的结果",
        one_result: "找到 1 条与「[SEARCH_TERM]」相关的结果",
        alt_search: "未找到「[SEARCH_TERM]」，显示「[DIFFERENT_TERM]」的结果",
        search_suggestion: "未找到「[SEARCH_TERM]」相关结果，可尝试：[DIFFERENT_TERMS]",
        searching: "正在搜索「[SEARCH_TERM]」…",
      },
    });
  });
}

function displaySearch() {
  document.body.classList.add("overflow-hidden");
  wrapper.classList.remove("invisible");
  searchVisible = true;
  ensurePagefindUI().then(function () {
    var input = document.querySelector("#search .pagefind-ui__search-input");
    if (input) input.focus();
  });
}

function hideSearch() {
  document.body.classList.remove("overflow-hidden");
  wrapper.classList.add("invisible");
  searchVisible = false;
}

if (showButton) showButton.addEventListener("click", displaySearch);
if (showButtonMobile) showButtonMobile.addEventListener("click", displaySearch);
if (hideButton) hideButton.addEventListener("click", hideSearch);
if (wrapper) wrapper.addEventListener("click", hideSearch);
if (modal) {
  modal.addEventListener("click", function (event) {
    event.stopPropagation();
  });
}

document.addEventListener("keydown", function (event) {
  if (event.key === "/") {
    var active = document.activeElement;
    var tag = active && active.tagName;
    var isInputField = tag === "INPUT" || tag === "TEXTAREA" || (active && active.isContentEditable);
    if (!searchVisible && !isInputField) {
      event.preventDefault();
      displaySearch();
    }
  }
  if (event.key === "Escape" && searchVisible) {
    hideSearch();
  }
});
