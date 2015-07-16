var Animate, ClearFix$, HoverBtn, InlineBlock, KeyFrames, LineSize, MediaQuery, Mixin, PosAbs, PosRel, Size, TextEllip$, Transit, Vendor, bgi, bw, gold, goldR, hsl, hsla, isIeLessThan9, linearGrad, num, parse, parsePropName, parseR, parseSelectors, pc, px, radialGrad, reTag, repeatGrad, rgb, rgba, tag, unTag, unit;

tag = function(cssText, id) {
  var styleEl;
  styleEl = document.createElement('style');
  if (id) {
    styleEl.id = id;
  }
  styleEl.type = 'text/css';
  if (isIeLessThan9) {
    styleEl.appendChild(document.createTextNode(cssText));
  } else {
    styleEl.styleSheet.cssText = cssText;
  }
  document.head = document.head || document.getElementsByTagName('head')[0];
  document.head.appendChild(styleEl);
  return styleEl;
};

reTag = function(cssText, styleEl) {
  if (isIeLessThan9) {
    styleEl.styleSheet.cssText = cssText;
  } else {
    styleEl.childNodes[0].textContent = cssText;
  }
  return styleEl;
};

unTag = function(styleEl) {
  if (styleEl) {
    return document.head.removeChild(styleEl);
  }
};

isIeLessThan9 = function() {
  var div;
  div = document.createElement('div');
  div.innerHTML = "<!--[if lt IE 9]><i></i><![endif]-->";
  return div.getElementsByTagName("i").length === 1;
};

parseR = function(selectors, mss, indent, lineEnd) {
  var cssRule, key, newSelectors, sel, subCssRule, subSel, subSelectors, val;
  cssRule = '';
  subCssRule = '';
  newSelectors = void 0;
  for (key in mss) {
    val = mss[key];
    if (key[0] === '@') {
      if (typeof val === "object") {
        subCssRule += key + "{" + lineEnd + (parseR([''], val, indent, lineEnd)) + "}" + lineEnd;
      } else {
        subCssRule += key + " " + val + ";" + lineEnd;
      }
    } else {
      if (typeof val === "object") {
        subSelectors = parseSelectors(key);
        newSelectors = [
          (function() {
            var j, len, results;
            results = [];
            for (j = 0, len = subSelectors.length; j < len; j++) {
              subSel = subSelectors[j];
              results.push((function() {
                var len1, m, results1;
                results1 = [];
                for (m = 0, len1 = selectors.length; m < len1; m++) {
                  sel = selectors[m];
                  results1.push("" + sel + subSel);
                }
                return results1;
              })());
            }
            return results;
          })()
        ];
        subCssRule += parseR(newSelectors, val, indent, lineEnd);
      } else {
        cssRule += "" + indent + (parsePropName(key)) + ":" + val + ";" + lineEnd;
      }
    }
  }
  return (cssRule !== '' ? (selectors.join(',' + lineEnd)) + "{" + lineEnd + cssRule + "}" + lineEnd : '') + subCssRule;
};

parse = function(mss, pretty) {
  var indent;
  if (pretty == null) {
    pretty = false;
  }
  return indent = parseR([''], mss, (pretty ? '  ' : ''), (pretty ? '\n' : ''));
};

parseSelectors = function(selectorString) {
  var firstChar, j, len, nest, ref, ref1, results, sel, selectors;
  selectors = selectorString.split('_');
  results = [];
  for (j = 0, len = selectors.length; j < len; j++) {
    sel = selectors[j];
    nest = ' ';
    if ((firstChar = sel[0]) === '&') {
      sel = sel.slice(1);
      nest = '';
    }
    switch (true) {
      case firstChar === '$':
        if (('a' <= (ref = sel[1]) && ref <= 'z')) {
          results.push(':' + sel.slice(1));
        } else if (('A' <= (ref1 = sel[1]) && ref1 <= 'Z')) {
          results.push(nest + '#' + sel[1].toLowerCase() + sel.slice(2));
        } else {
          results.push(void 0);
        }
        break;
      case ('A' <= firstChar && firstChar <= 'Z'):
        results.push(nest + '.' + sel);
        break;
      case ('a' <= firstChar && firstChar <= 'z'):
        results.push(nest + firstChar.toLowerCase() + sel.slice(1));
        break;
      default:
        results.push(nest + sel);
    }
  }
  return results;
};

parsePropName = function(prop) {
  var c, j, len, transformed;
  transformed = '';
  for (j = 0, len = prop.length; j < len; j++) {
    c = prop[j];
    if (('A' <= c && c <= 'Z')) {
      transformed += "-" + c.toLowerCase();
    } else {
      transformed += c;
    }
  }
  return transformed;
};

num = parseInt;

unit = function(str) {
  switch (str.slice(-1)) {
    case '%':
      return '%';
    default:
      return str.slice(-2);
  }
};

px = function() {
  var argsN, i, s;
  s = '';
  i = 0;
  argsN = arguments.length - 1;
  while (i < argsN) {
    s += arguments[i++] + 'px ';
  }
  s += arguments[i] + 'px';
  return s;
};

pc = function() {
  var argsN, i, s;
  s = '';
  i = 0;
  argsN = arguments.length - 1;
  while (i < argsN) {
    s += arguments[i++] + '% ';
  }
  s += arguments[i] + '%';
  return s;
};

gold = function(v) {
  return Math.round(v * 0.618);
};

goldR = function(v) {
  return Math.round(v / 0.618);
};

bgi = function(imgURL, position, repeat, attachment, clip) {
  if (position == null) {
    position = CENTER;
  }
  if (repeat == null) {
    repeat = 'no-repeat';
  }
  return "url(#imgURL) position repeat" + (attachment ? attachment : '') + (clip ? clip : '');
};

rgb = function(r, g, b) {
  return "rgb(" + r + "," + g + "," + b + ")";
};

bw = function(bw) {
  return "rgb(" + bw + "," + bw + "," + bw + ")";
};

rgba = function(r, g, b, a) {
  return "rgba(" + r + "," + g + "," + b + "," + a + ")";
};

hsl = function(h, s, l) {
  return "hsl(" + h + "," + s + "%," + l + "%)";
};

hsla = function(r, g, b, a) {
  return "hsla(" + h + "," + s + "%," + l + "%," + a + ")";
};

linearGrad = function(sideOrAngle, stops) {
  return "linear-gradient(#sideOrAngle," + (stops.join(',')) + ")";
};

radialGrad = function(stops) {
  return "radial-gradient(" + (stops.join(',')) + ")";
};

repeatGrad = function(sideOrAngle, stops) {
  return "repeat-gradient(#sideOrAngle," + (stops.join(',')) + ")";
};

Mixin = function(mssMix) {
  return function(mss) {
    var k, v;
    for (k in mssMix) {
      v = mssMix[k];
      mss[k] = v;
    }
    return mss;
  };
};

Size = function(width, height) {
  return function(mss) {
    if (width != null) {
      mss.width = width;
    }
    if (height != null) {
      mss.height = height;
    }
    return mss;
  };
};

PosAbs = function(top, right, bottom, left) {
  return function(mss) {
    mss.position = 'absolute';
    if (top != null) {
      mss.top = top;
    }
    if (right != null) {
      mss.right = right;
    }
    if (bottom != null) {
      mss.bottom = bottom;
    }
    if (left != null) {
      mss.left = left;
    }
    return mss;
  };
};

PosRel = function(top, right, bottom, left) {
  return function(mss) {
    mss.position = 'relative';
    if (top != null) {
      mss.top = top;
    }
    if (right != null) {
      mss.right = right;
    }
    if (bottom != null) {
      mss.bottom = bottom;
    }
    if (left != null) {
      mss.left = left;
    }
    return mss;
  };
};


/*
 * transistion shorthand with default value
 * type cant be :
 *
 * @param prop {String}
 * @param time {String}
 * @param type {String}
 * @param delay {String}
 * @return {mss}
 */

Transit = function(prop, time, type, delay) {
  if (type == null) {
    type = 'ease';
  }
  if (delay == null) {
    delay = '0s';
  }
  return function(mss) {
    mss.transition = "#prop #time #type #delay";
    return mss;
  };
};

InlineBlock = function(directions) {
  if (directions == null) {
    directions = 'left';
  }
  return function(mss) {
    mss.display = 'inline-block';
    mss.float = directions;
    mss['*zoom'] = 1;
    mss['*display'] = 'inline';
    return mss;
  };
};

LineSize = function(lineHeight, fontS) {
  return function(mss) {
    mss.verticalAlign = 'middle';
    if (lineHeight != null) {
      mss.height = mss.lineHeight = lineHeight;
    }
    if (fontS != null) {
      mss.fontSize = fontS;
    }
    return mss;
  };
};

HoverBtn = function(textcolor, bgcolor, cur) {
  if (cur == null) {
    cur = 'pointer';
  }
  return function(mss) {
    if (mss.$hover == null) {
      mss.$hover = {};
    }
    mss.$hover.cursor = cur;
    if (textcolor) {
      mss.$hover.color = textcolor;
    }
    if (bgcolor) {
      mss.$hover.background = bgcolor;
    }
    return mss;
  };
};

Vendor = function(prop) {
  return function(mss) {
    var PropBase, v;
    if ((v = mss[prop]) != null) {
      PropBase = prop[0].toUpperCase() + prop.slice(1);
      mss['Moz' + PropBase] = v;
      mss['Webkit' + PropBase] = v;
      mss['Ms' + PropBase] = v;
    }
    return mss;
  };
};

Animate = function(name, time, type, delay, iter, direction, fill, state) {
  if (type == null) {
    type = 'linear';
  }
  if (delay == null) {
    delay = '0s';
  }
  if (iter == null) {
    iter = 1;
  }
  return function(mss) {
    mss.animate = (name + " " + time + " " + type + " " + delay + " " + iter) + (direction != null ? direction : '') + (fill != null ? fill : '') + (state != null ? state : '');
    return mss;
  };
};

TextEllip$ = function(mss) {
  mss.whiteSpace = 'nowrap';
  mss.overflow = 'hidden';
  mss.textOverflow = 'ellipsis';
  return mss;
};

ClearFix$ = function(mss) {
  mss['*zoom'] = 1;
  mss.$before_$after = {
    content: "''",
    display: 'table'
  };
  mss.$after = {
    clear: 'both'
  };
  return mss;
};

MediaQuery = function(queryObj) {
  return function(mss) {
    var k, mediaType, obj, queryRules, queryStrArr, v;
    queryStrArr = (function() {
      var results;
      results = [];
      for (mediaType in queryObj) {
        queryRules = queryObj[mediaType];
        if (mediaType[0] === '_') {
          mediaType = 'not ' + mediaType.slice(1);
        }
        if (mediaType[0] === '$') {
          mediaType = 'only ' + mediaType.slice(1);
        }
        if (queryRules) {
          results.push(mediaType + ' and ' + ((function() {
            var results1;
            results1 = [];
            for (k in queryRules) {
              v = queryRules[k];
              results1.push('(' + (parsePropName(k)) + (v ? ':' + v : '') + ')');
            }
            return results1;
          })()).join(' and '));
        } else {
          results.push(mediaType);
        }
      }
      return results;
    })();
    return (
      obj = {},
      obj["@media " + (queryStrArr.join(','))] = mss,
      obj
    );
  };
};

KeyFrames = function(name) {
  return function(mss) {
    var k, keyFramesObj, max, obj, v;
    keyFramesObj = {};
    max = 0;
    for (k in mss) {
      max = Math.max(max, Number.parseFloat(k));
    }
    for (k in mss) {
      v = mss[k];
      keyFramesObj[(Number.parseFloat(k)) * 100 / max + '%'] = v;
    }
    return (
      obj = {},
      obj["@keyframes " + name] = keyFramesObj,
      obj
    );
  };
};

module.exports = {
  parse: parse,
  tag: tag,
  parseSelectors: parseSelectors,
  parsePropName: parsePropName
};
