function changeLang(){
  var langSelect = document.getElementById("lang");
  changeLang(varSelect);
}

function changeLang(langSelect) {
  var lang = langSelect.options[langSelect.selectedIndex].value;
  if (lang != null) {
    if (lang == "") {
        window.top.location = getBaseURL();
    } else {
        window.top.location = getBaseURL() + lang + '/';
    }
  }
}

function getBaseURL() {
  return window.location.protocol + '//' + window.location.host + '/';
}

function getPageLanguage() {
  var baseURL = getBaseURL();
  var url = window.location.href;
  if (url == baseURL) {
    return "";
  } else {
    var urlNoBase = url.replace(baseURL, '');
    var index = urlNoBase.indexOf('/')
    return index == -1 ? urlNoBase : urlNoBase.substring(0, index);
  }
}

function setLangSelectLanguage() {
  var langSelect = document.getElementById("lang");
  var pageLang = getPageLanguage();
  setSelectedLang(langSelect, pageLang);
}

function setSelectedLang(langSelect, pageLang) {
  var langIndex = 0;
  for (var i = 0; i < langSelect.options.length; i++) {
    var option = langSelect.options[i];
    if (option.value == pageLang) {
      langIndex = i;
      break;
    }
  }
  langSelect.selectedIndex = langIndex;
}
