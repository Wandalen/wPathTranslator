( function _FileExecutor_s_( ) {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  _.include( 'wTesting' );

  require( '../executor/FileExecutor.s' );

}

var _ = wTools;

if( typeof __dirname === 'undefined' )
return;

// --
// tests
// --

var samples = {}

// samples.singleFile =
// {
//   description : 'single file',
//   path : 'f1.js',
//   expected :
//   {
//     "." : "(function() {\n\ndebugger;\nconsole.log( 'f1:before' );\n\n//\nconsole.log( '0 1 2 3 4 5 6 7 8 ' );\n//\n\ndebugger;\nconsole.log( 'f1:after' );\n\n});\n"
//   },
// }
//
// samples.singleFileWithSingleLine =
// {
//   description : 'single file with single line',
//   path : 'f2.js',
//   expected :
//   {
//     "." : "(function() {\n\ndebugger;\nconsole.log( 'f2:before' );\n\n/**/console.log( 'x' );/**/\n\ndebugger;\nconsole.log( 'f2:after' );\n\n});\n"
//   },
// }
//
// samples.environment =
// {
//   description : 'environment variables',
//   path : 'env.js',
//   expected :
//   {
//     "." : "(function() {\n\ndebugger;\nconsole.log( 'env:before' );\n\n//\n\nconsole.log( '__dirname : /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp' );\nconsole.log( '__filename : /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp/env.js' );\nconsole.log( \"./env.js\" );\nconsole.log( \"./env.js\" );\nconsole.log( \"./env.js\" );\n\n//\n\ndebugger;\nconsole.log( 'env:after' );\n\n});\n"
//   },
// }
//
// samples.environmentWithVirtualRoot =
// {
//   description : 'environment variables with virtual root',
//   path : 'env.js',
//   rootPath : '..',
//   virtualCurrentDirPath : '/',
//   expected :
//   {
//     "." : "(function() {\n\ndebugger;\nconsole.log( 'env:before' );\n\n//\n\nconsole.log( '__dirname : /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp' );\nconsole.log( '__filename : /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp/env.js' );\nconsole.log( \"./template.tmp/env.js\" );\nconsole.log( \"./template.tmp/env.js\" );\nconsole.log( \"./template.tmp/env.js\" );\n\n//\n\ndebugger;\nconsole.log( 'env:after' );\n\n});\n"
//   },
// }

samples.inlcudeOne =
{
  description : 'include one file from another',
  path : 'f2/**',
  usedFiles :
  {
    "./f1.js" : [],
    "./f2.js" : [ `./f1.js` ]
  },
  expected :
  {
    "f1.js" : "(function() {\n\ndebugger;\nconsole.log( 'f1:before' );\n\n//\nconsole.log( '0 1 2 3 4 5 6 7 8 ' );\n//\n\ndebugger;\nconsole.log( 'f1:after' );\n\n});\n",
    "f2.js" : "(function() {\n\ndebugger;\nconsole.log( 'f2:before' );\n\n//\n(function() {\n\ndebugger;\nconsole.log( 'f1:before' );\n\n//\nconsole.log( '0 1 2 3 4 5 6 7 8 ' );\n//\n\ndebugger;\nconsole.log( 'f1:after' );\n\n});\n//\n\ndebugger;\nconsole.log( 'f2:after' );\n\n});\n"
  }
}

samples.inlcudeManyStatic =
{
  description : 'include many static files from one',
  path : 'f3static/b.js',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./b.js" : [ `./a.js`, `./c.js` ],
  },
  expected :
  {
    "." : "(function() {\n\ndebugger;\nconsole.log( 'b:before' );\n\n//\n(function() {\n\nconsole.log( 'a.js' );\n\n});\n(function() {\n\nconsole.log( 'c.js' );\n\n});\n// last line\n//\n\ndebugger;\nconsole.log( 'b:after' );\n\n});\n"
  },
}

samples.inlcudeManyDynamic =
{
  description : 'include many dynamic files from one',
  path : 'f3/b.js',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./b.js" : [ `./a.js`, `./c.js` ],
  },
  expected :
  {
    "." : "(function() {\n\ndebugger;\nconsole.log( 'b:before' );\n\n//\n(function() {\n\ndebugger;\nconsole.log( 'a:before' );\n\n//\n\nconsole.log( \"./a.js\" );\n//\n\ndebugger;\nconsole.log( 'a:after' );\n\n});\n(function() {\n\ndebugger;\nconsole.log( 'c:before' );\n\n//\nconsole.log( '0 1 2 3 4 5 6 7 8 ' );\n//\n\ndebugger;\nconsole.log( 'c:after' );\n\n});\n// last line\n//\n\ndebugger;\nconsole.log( 'b:after' );\n\n});\n"
  }
}

samples.inlcudeManyDynamicNoChildrenIncluding =
{
  description : 'include many dynamic files from one, not allowing children including',
  path : 'f3/b.js',
  allowIncludingChildren : 0,
  throwingError : 1,
  expected : {},
}

samples.inlcudeTakingAttributesIntoAccount =
{
  description : 'include taking attributes into account',
  path : 'attrs/**',
  allowIncludingChildren : 0,
  usedFiles :
  {
    "./a.js" : [ `./c/c1.s`, `./c/c2.js`, `./c/c3.ss` ],
    "./b1.js" : [ `./a.js`, `./c/c1.s`, `./c/c2.js`, `./c/c3.ss` ],
    "./b2.js" : [ `./a.js`, `./c/c1.s`, `./c/c2.js`, `./c/c3.ss` ],
    "./c1.html" : [ `./a.js`, `./c/c1.s`, `./c/c2.js`, `./c/c3.ss` ],
    "./c2.html" : [ `./a.js`, `./c/c1.s`, `./c/c2.js`, `./c/c3.ss`, `./b1.js`, `./a.js`, `./c/c1.s`, `./c/c2.js`, `./c/c3.ss`, `./b2.js`, `./a.js`, `./c/c1.s`, `./c/c2.js`, `./c/c3.ss` ],
    "./c/c1.s" : [],
    "./c/c2.js" : [],
    "./c/c3.ss" : [],
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b1.js" : "(function() {\n\ndebugger;\nconsole.log( 'b:before' );\n\n//\n(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n//\n\ndebugger;\nconsole.log( 'b:after' );\n\n});\n",
    "b2.js" : "(function() {\n\ndebugger;\nconsole.log( 'b:before' );\n\n//\n(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n//\n\ndebugger;\nconsole.log( 'b:after' );\n\n});\n",
    "c1.html" : "<html>\n<script src=\"/a.js\" type=\"text/javascript\" ></script>\n</html>\n",
    "c2.html" : "<html>\n<script src=\"/a.js\" type=\"text/javascript\" ></script>\n<script src=\"/b1.js\" type=\"text/javascript\" ></script>\n<script src=\"/b2.js\" type=\"text/javascript\" ></script>\n</html>\n",
    "c" :
    {
      "c1.s" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.ss" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n"
    }
  }
}

samples.inlcudeTakingAttributesIntoAccountWithIf =
{
  description : 'include taking attributes into account, with if',
  path : 'attrsIf/**',
  allowIncludingChildren : 0,
  usedFiles :
  {
    "./a.js" : [ `./c/c1.s`, `./c/c3.ss` ],
    "./b.html" : [ `./c/c1.s`, `./c/c3.ss` ],
    "./c/c1.s" : [],
    "./c/c2.js" : [],
    "./c/c3.ss" : []
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b.html" : "<html>\n<script src=\"/c/c1.s\" type=\"text/javascript\" ></script>\n<script src=\"/c/c3.ss\" type=\"text/javascript\" ></script>\n</html>\n",
    "c" :
    {
      "c1.s" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.ss" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n"
    }
  },
}

samples.attributesWithPreferences =
{
  description : 'include taking attributes into account, with preferences',
  path : 'attrsPreferences/**',
  allowIncludingChildren : 0,
  usedFiles :
  {
    "./a.js" : [ `./c/c1.s`, `./c/c3.ss` ],
    "./b.html" : [ `./c/c1.s`, `./c/c3.ss` ],
    "./c/c1.s" : [],
    "./c/c2.js" : [],
    "./c/c3.ss" : []
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b.html" : "<html>\n<script src=\"/c/c1.s\" type=\"text/javascript\" ></script>\n<script src=\"/c/c3.ss\" type=\"text/javascript\" ></script>\n</html>\n",
    "c" :
    {
      "c1.s" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.ss" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n"
    }
  }
}

samples.attributesWithNonExecutiveFile =
{
  description : 'include taking attributes into account, with non executive files and onIncludeFromat',
  path : 'attrsNonExec/**',
  allowIncludingChildren : 0,
  usedFiles :
  {
    "./a.js" : [ `./c/c1.s`, `./c/c3.ss`, `./c/c4.css` ],
    "./b.html" : [ `./c/c1.s`, `./c/c3.ss`, `./c/c4.css` ],
    "./c/c1.s" : [],
    "./c/c2.js" : [],
    "./c/c3.ss" : [],
    "./c/c4.css" : [],
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\nvar style = `\\nbody > div\\n{\\n  font-size : 2em;\\n}\\n`;// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b.html" : "<html>\n\n  <script src=\"/c/c1.s\" type=\"text/javascript\" ></script>\n  <script src=\"/c/c3.ss\" type=\"text/javascript\" ></script>\n  <link href=\"/c/c4.css\" rel=\"stylesheet\" type=\"text/css\" >\n\n</html>\n",
    "c" :
    {
      "c1.s" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.ss" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n",
      "c4.css" : "\nbody > div\n{\n  font-size : 2em;\n}\n",
    }
  },
}
/**/
samples.chunkFromatter =
{
  description : 'chunk formatter',
  path : 'chunkFormatter/**',
  allowIncludingChildren : 1,
  context : { release : 1 },

  usedFiles :
  {
    "./a.js" : [ `./c/c1.s`, `./c/c3.ss`, `./c/c4.less`, `./c/c5.less` ],
    "./b.html" : [ `./c/c1.s`, `./c/c3.ss`, `./c/c4.less`, `./c/c5.less` ],
    "./c/c1.s" : [],
    "./c/c2.js" : [],
    "./c/c3.ss" : [],
    "./c/c4.less" : [],
    "./c/c5.less" : [],
    "./b.manual.js" : undefined
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\nvar style = `\\n// c4\\n\\nbody > div\\n{\\n  font-size : 2em;\\n}\\n`;var style = `\\n// c5\\n\\nbody > div\\n{\\n  font-size : 2em;\\n}\\n`;// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b.html" : "<html>\n\n  \n  /*\n  script\n  /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp/chunkFormatter/c/c1.s\n  /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp/chunkFormatter/c/c3.ss\n  */\n  \n  /*\n  style\n  /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp/chunkFormatter/c/c4.less\n  /pro/web/Dave/app/builder/include/dwtools/amid/executor/template.tmp/chunkFormatter/c/c5.less\n  */\n  <script src=\"/b.manual.js\" type=\"text/javascript\" ></script>\n\n</html>\n",
    "c" :
    {
      "c1.s" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.ss" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n",
      "c4.less" : "\n// c4\n\nbody > div\n{\n  font-size : 2em;\n}\n",
      "c5.less" : "\n// c5\n\nbody > div\n{\n  font-size : 2em;\n}\n",
    }
  }
}
/**/
samples.normalCaseSimplified =
{
  description : 'normal case simplified',
  path : 'normalSimplified/a.js',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./a.js" : [ `./b/b1.js`, `./b/b2.js`, `./b/b3.js` ]
  },
  expected :
  {
    "." : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n"
  },
}

samples.normalCaseSpecificEntry =
{
  description : 'normal case to use as workpiece for other cases, specific entry point',
  path : 'normal/a.js',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./a.js" : [ `./b/b1.js`, `./b/b2.js`, `./c/c1.js`, `./c/c2.js`, `./c/c3.js`, `./b/b3.js` ]
  },
  expected :
  {
    "." : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
  },
}

samples.normalCase =
{
  description : 'normal case to use as workpiece for other cases, glob entry point',
  path : 'normal/**',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./a.js" : [ `./b/b1.js`, `./b/b2.js`, `./c/c1.js`, `./c/c2.js`, `./c/c3.js`, `./b/b3.js` ],
    "./b/b1.js" : [],
    "./b/b2.js" : [ `./c/c1.js`, `./c/c2.js`, `./c/c3.js` ],
    "./b/b3.js" : [],
    "./c/c1.js" : [],
    "./c/c2.js" : [],
    "./c/c3.js" : []
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b" :
    {
      "b1.js" : "(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n",
      "b2.js" : "(function() {\n\nconsole.log( 'b2:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n",
      "b3.js" : "(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n"
    },
    "c" :
    {
      "c1.js" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.js" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n"
    }
  },
}

samples.normalCase2 =
{
  description : 'complicated normal case, glob entry point',
  path : 'normal2/**',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./a1.js" : [],
    "./a2.js" : [ `./a1.js` ],
    "./b.js" : [ `./a2.js`, `./a1.js`, `./c/c1.js`, `./c/c2.js`, `./d/d1.js`, `./d/d2.js`, `./d/d3.js`, `./c/c3.js` ],
    "./c/c1.js" : [],
    "./c/c2.js" : [ `./d/d1.js`, `./d/d2.js`, `./d/d3.js` ],
    "./c/c3.js" : [],
    "./d/d1.js" : [],
    "./d/d2.js" : [],
    "./d/d3.js" : []
  },
  expected :
  {
    "a1.js" : "(function() {\n\nconsole.log( 'a1:before' );\n\n//\n// a1\n//\n\nconsole.log( 'a1:after' );\n\n});\n",
    "a2.js" : "(function() {\n\nconsole.log( 'a2:before' );\n\n//\n(function() {\n\nconsole.log( 'a1:before' );\n\n//\n// a1\n//\n\nconsole.log( 'a1:after' );\n\n});\n// a2\n//\n\nconsole.log( 'a2:after' );\n\n});\n",
    "b.js" : "(function() {\n\nconsole.log( 'b:before' );\n\n//\n(function() {\n\nconsole.log( 'a2:before' );\n\n//\n(function() {\n\nconsole.log( 'a1:before' );\n\n//\n// a1\n//\n\nconsole.log( 'a1:after' );\n\n});\n// a2\n//\n\nconsole.log( 'a2:after' );\n\n});\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n(function() {\n\nconsole.log( 'd1:before' );\n\n//\n// d1\n//\n\nconsole.log( 'd1:after' );\n\n});\n(function() {\n\nconsole.log( 'd2:before' );\n\n//\n// d2\n//\n\nconsole.log( 'd2:after' );\n\n});\n(function() {\n\nconsole.log( 'd3:before' );\n\n//\n// d3\n//\n\nconsole.log( 'd3:after' );\n\n});\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// b\n//\n\nconsole.log( 'b:after' );\n\n});\n",
    "c" :
    {
      "c1.js" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n(function() {\n\nconsole.log( 'd1:before' );\n\n//\n// d1\n//\n\nconsole.log( 'd1:after' );\n\n});\n(function() {\n\nconsole.log( 'd2:before' );\n\n//\n// d2\n//\n\nconsole.log( 'd2:after' );\n\n});\n(function() {\n\nconsole.log( 'd3:before' );\n\n//\n// d3\n//\n\nconsole.log( 'd3:after' );\n\n});\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.js" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n"
    },
    "d" :
    {
      "d1.js" : "(function() {\n\nconsole.log( 'd1:before' );\n\n//\n// d1\n//\n\nconsole.log( 'd1:after' );\n\n});\n",
      "d2.js" : "(function() {\n\nconsole.log( 'd2:before' );\n\n//\n// d2\n//\n\nconsole.log( 'd2:after' );\n\n});\n",
      "d3.js" : "(function() {\n\nconsole.log( 'd3:before' );\n\n//\n// d3\n//\n\nconsole.log( 'd3:after' );\n\n});\n"
    }
  }
}

samples.severalSamfIncludeToolss =
{
  description : 'several same includes',
  path : 'severalSamfIncludeToolss/**',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./a.js" : [ `./b/b1.js`, `./b/b3.js`, `./b/b3.js`, `./b/b2.js`, `./b/b3.js`, `./b/b2.js` ],
    "./b/b1.js" : [ `./b/b3.js`, `./b/b3.js` ],
    "./b/b2.js" : [],
    "./b/b3.js" : []
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b" :
    {
      "b1.js" : "(function() {\n\nconsole.log( 'b1:before' );\n\n//\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n",
      "b2.js" : "(function() {\n\nconsole.log( 'b2:before' );\n\n//\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n",
      "b3.js" : "(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n"
    }
  },
}

samples.includeError =
{
  description : 'deep include error because of undefined returned',
  path : 'includeError/a.js',
  allowIncludingChildren : 1,
  throwingError : 1,
  expected :
  {
  },
}

samples.specificEnd =
{
  description : 'specific ends',
  path : 'ends/a*.s',
  checkPath : 'ends',
  allowIncludingChildren : 1,
  usedFiles :
  {
    "./a1.s" : [ `./b/b1.s` ],
    "./a2.s" : [ `./b/b1.s`, `./b/b2.js` ],
  },
  expected :
  {
    "a1.s" : "(function() {\n\nconsole.log( 'a1:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n// a1\n//\n\nconsole.log( 'a1:after' );\n\n});\n",
    "a2.s" : "(function() {\n\nconsole.log( 'a2:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n// a2\n//\n\nconsole.log( 'a2:after' );\n\n});\n",
    "b" :
    {
      "b1.s" : "(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n",
      "b2.js" : "(function() {\n\nconsole.log( 'b2:before' );\n\n//\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n",
      "b3.ss" : "(function() {\n\nconsole.log( 'b3:before' );\n\n//\n//>-->//\nreturn `// b3`;\n//<--<//\n//\n\nconsole.log( 'b3:after' );\n\n});\n"
    }
  },
}

samples.dalays =
{
  description : 'include with delays in chunks and formatters',
  path : 'delays/**',
  allowIncludingChildren : 0,
  asyncFormatterCallCounter : 3,
  usedFiles :
  {
    "./a.js" : [ `./b/b1.js`, `./b/b2.js`, `./c/c1.js2`, `./c/c2.js2`, `./c/c3.js2`, `./b/b3.js` ],
    "./b/b1.js" : [],
    "./b/b2.js" : [ `./c/c1.js2`, `./c/c2.js2`, `./c/c3.js2` ],
    "./b/b3.js" : [],
    "./c/c1.js2" : [],
    "./c/c2.js2" : [],
    "./c/c3.js2" : [],
  },
  expected :
  {
    "a.js" : "(function() {\n\nconsole.log( 'a:before' );\n\n//\n(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n(function() {\n\nconsole.log( 'b2:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n// a\n//\n\nconsole.log( 'a:after' );\n\n});\n",
    "b" :
    {
      "b1.js" : "(function() {\n\nconsole.log( 'b1:before' );\n\n//\n// b1\n//\n\nconsole.log( 'b1:after' );\n\n});\n",
      "b2.js" : "(function() {\n\nconsole.log( 'b2:before' );\n\n//\n(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n// b2\n//\n\nconsole.log( 'b2:after' );\n\n});\n",
      "b3.js" : "(function() {\n\nconsole.log( 'b3:before' );\n\n//\n// b3\n//\n\nconsole.log( 'b3:after' );\n\n});\n"
    },
    "c" :
    {
      "c1.js2" : "(function() {\n\nconsole.log( 'c1:before' );\n\n//\n// c1\n//\n\nconsole.log( 'c1:after' );\n\n});\n",
      "c2.js2" : "(function() {\n\nconsole.log( 'c2:before' );\n\n//\n// c2\n//\n\nconsole.log( 'c2:after' );\n\n});\n",
      "c3.js2" : "(function() {\n\nconsole.log( 'c3:before' );\n\n//\n// c3\n//\n\nconsole.log( 'c3:after' );\n\n});\n",
    }
  },

}

//

function executorMakeFor( path )
{
  var context = this;

  _global_.asyncFormatterCallCounter = 0;

  context.dstPath = _.pathJoin( __dirname,'./template.tmp' );
  context.srcPath = _.pathJoin( __dirname,'./template.test' );

  var dstPath = _.pathsJoin( context.dstPath, _.pathSplit( path )[ 0 ] );
  var srcPath = _.pathsJoin( context.srcPath, _.pathSplit( path )[ 0 ] );

  context.fileProvider.filesCopy
  ({
    dst : dstPath,
    src : srcPath,
    allowDelete : 1,
    verbosity : 0,
  });

  context.executor = new wFileExecutor();

  context.executor.linkAttributeDefault = 'js';

  //

  context.executor.fileCategorizers =
  {
    'html' : function( file )
    {
      return _.arrayHas( [ 'html','htm' ],file.ext );
    },
    'html.withChunkFormat' : [ 'html2' ],
    'script' : function( file )
    {
      return _.arrayHas( [ 'ss','js','s' ],file.ext );
    },
    'script.server' : function( file )
    {
      return _.arrayHas( [ 'ss','s' ],file.ext );
    },
    'script.client' : function( file )
    {
      return _.arrayHas( [ 'js','s' ],file.ext );
    },
    'script.withAsyncFormatter' : [ 'js2' ],
    'style' : [ 'css','less' ],
    'style.css' : 'css',
    'style.less' : 'less',
    'inline' : 'inline',
  }

  //

  context.executor.linkCategorizers =
  {
    'script.in.html' : function( o )
    {
      if( [ 'html','htm' ].indexOf( o.user.ext ) === -1 )
      return false;
      if( [ 'ss','js','s' ].indexOf( o.used.ext ) === -1 )
      return false;
      return 'script.in.html';
    },
  }

  //

  context.executor.arbitraryCategorizers =
  {
    'release' : function( o )
    {
      return this.context.release ? 'release' : 'debug';
    },
  }

  //

  context.executor.linkFormatters =
  [
    {
      ifAll : [ 'script','in.html' ],
      ifNone : [ 'in.release' ],
      format : function( o )
      {
        debugger;
        o.frame.result = '<script src="' + o.frame.user.fileFrame.pathTranslator.virtualFor( o.frame.used.fileFrame.file.absolute ) + '" type="text/javascript" ></script>\n';
      },
    },
    {
      ifAll : [ 'style','in.html' ],
      ifNone : [ 'release' ],
      format : function( o )
      {
        o.frame.result = '<link href="' + o.frame.user.fileFrame.pathTranslator.virtualFor( o.frame.used.fileFrame.file.absolute ) + '" rel="stylesheet" type="text/css" >\n';
      },
    },
    {
      ifAll : [ 'script','in.html','release' ],
      format : function( o )
      {
        debugger;
        o.frame.result = '';
      },
    },
    {
      ifAll : [ 'style','in.html','release' ],
      format : function( o )
      {
        o.frame.result = '';
      },
    },
    {
      ifAll : [ 'script.withAsyncFormatter' ],
      format : function( o )
      {
        _global_.asyncFormatterCallCounter += 1;
        var result = o.frame.result;
        o.frame.result = _.timeOut( 1000,function()
        {
          debugger;
          return result;
        });
      },
    },
  ]

  //

  context.executor.chunkFormatters =
  [

    {
      name : 'format.script',
      ifAll : [ 'release','html' ],
      format : function( o )
      {

        if( !o.frame.usedIncludeFrames.length )
        return;

        var paths = _.entityFilter( o.frame.usedFileFrames,function( e )
        {
          return _.arrayHas( e.categories,'script' ) ? e.file.absolute : undefined;
        });

        var read = wTools.fileProvider.filesRead({ paths : paths, throwing : 1, sync : 1 });

        o.frame.result += '\n/*' + '\nscript\n' + paths.join( '\n' ) + '\n*/\n';

      },
    },

    {
      name : 'format.style',
      ifAll : [ 'release','html' ],
      onlyForUsedFiles : { ifAll : [ 'style' ] },
      format : function( o )
      {

        var joinedFilePath = _.pathJoin( o.frame.fileFrame.file.dir,o.frame.fileFrame.file.name + '.manual.js' );
        // var joinedFile = o.frame.fileFrame.file.clone( joinedFilePath );

        var paths = _.entitySelect( o.usedFileFrames,'*.file.absolute' );
        var read = wTools.fileProvider.filesRead({ paths : paths, throwing : 1, sync : 1 });
        o.frame.result += '\n/*' + '\nstyle\n' + paths.join( '\n' ) + '\n*/\n';
        // o.frame.result += joinedFile.relative + '\n';

        return o.executor.linkFormatExplicit
        ({
          filePath : joinedFilePath,
          removeCategories : [ 'release','in.release' ],
          formatter : o,
        });

      },
    },

  ],

  _global_.asyncFormatterCallCounter = 0;

}

//

function chunksSplit( test )
{

  test.description = 'empty chunk'; //

  var executor = new wFileExecutor();
  debugger;
  var chunks = executor._chunksSplit( '' );

  var expected =
  {
    chunks :
    [
      { line : 0, text : ``, index : 0, kind : 'static' }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/

  test.identical( chunks,expected );

  test.description = 'single text chunk'; //

  var executor = new wFileExecutor();
  var chunks = executor._chunksSplit( 'abc' );

  var expected =
  {
    chunks :
    [
      { line : 0, text : `abc`, index : 0, kind : 'static' }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/

  test.identical( chunks,expected );

  test.description = 'single code chunk'; //

  var executor = new wFileExecutor();
  var chunks = executor._chunksSplit( '//>-'+'->//abc//<-'+'-<//' );

  var expected =
  {
    chunks :
    [
      {
        line : 0,
        column : 0,
        index : 0,
        prefix : `//>-->//`,
        code : `abc`,
        lines : [ `abc` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/
  test.identical( chunks,expected );

  test.description = 'single code chunk with text chunk before'; //

  var executor = new wFileExecutor();
  var chunks = executor._chunksSplit( 'a //>-'+'->//abc//<-'+'-<//' );

  var expected =
  {
    chunks :
    [
      { line : 0, text : `a `, index : 0, kind : 'static' },
      {
        line : 0,
        column : 2,
        index : 1,
        prefix : `//>-->//`,
        code : `abc`,
        lines : [ `abc` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/
  test.identical( chunks,expected );

  test.description = 'single code chunk with text chunk after'; //

  var executor = new wFileExecutor();
  var chunks = executor._chunksSplit( '//>-'+'->//abc//<-'+'-<// b' );

  var expected =
  {
    chunks :
    [
      {
        line : 0,
        column : 0,
        index : 0,
        prefix : `//>-->//`,
        code : `abc`,
        lines : [ `abc` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      },
      { line : 0, text : ` b`, index : 1, kind : 'static' }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/
  test.identical( chunks,expected );

  test.description = 'two code chunks'; //

  var executor = new wFileExecutor();
  var chunks = executor._chunksSplit( '//>-'+'->//abc//<-'+'-<//' + '//>-'+'->//def//<-'+'-<//' );

  var expected =
  {
    chunks :
    [
      {
        line : 0,
        column : 0,
        index : 0,
        prefix : `//>-->//`,
        code : `abc`,
        lines : [ `abc` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      },
      {
        line : 0,
        column : 0,
        index : 1,
        prefix : `//>-->//`,
        code : `def`,
        lines : [ `def` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/
  test.identical( chunks,expected );

  test.description = 'two code chunks with text chunks'; //

  var executor = new wFileExecutor();
  var chunks = executor._chunksSplit( 'a//>-'+'->//abc//<-'+'-<//b' + 'c//>-'+'->//def//<-'+'-<//d' );

  var expected =
  {
    chunks :
    [
      { line : 0, text : `a`, index : 0, kind : 'static' },
      {
        line : 0,
        column : 1,
        index : 1,
        prefix : `//>-->//`,
        code : `abc`,
        lines : [ `abc` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      },
      { line : 0, text : `bc`, index : 2, kind : 'static' },
      {
        line : 0,
        column : 3,
        index : 3,
        prefix : `//>-->//`,
        code : `def`,
        lines : [ `def` ],
        tab : ``,
        postfix : `//<--<//`,
        kind : 'dynamic',
      },
      { line : 0, text : `d`, index : 4, kind : 'static' }
    ]
  }

  /*logger.log( _.toJstruct( chunks ) );*/
  test.identical( chunks,expected );

  debugger;
}

//

function samplesTest( test )
{
  var context = this;
  var con = new wConsequence().give();
  var executed, expected

  function sampleTest( sample )
  {
    test.description = sample.description;
    context.executorMakeFor( sample.path );
    context.executor.context = sample.context || Object.create( null );

    var path = _.pathsJoin( context.dstPath, sample.path );
    var checkPath = path;
    if( sample.checkPath )
    checkPath = _.pathsJoin( context.dstPath, sample.checkPath );
    var rootPath = sample.rootPath ? _.pathJoin( context.dstPath, sample.rootPath ) : undefined;
    var virtualCurrentDirPath = sample.virtualCurrentDirPath ? _.pathJoin( context.dstPath, sample.virtualCurrentDirPath ) : undefined;

    if( sample.throwingError )
    return test.shouldThrowErrorAsync( function()
    {
      executed = context.executor.include
      ({
        path : path,
        rootPath : rootPath,
        virtualCurrentDirPath : virtualCurrentDirPath,
        allowIncludingChildren : sample.allowIncludingChildren,
      });
      return executed.consequence;
    }).chokeThen();
    else
    {
      var pathTranslator;
      executed = context.executor.include
      ({
        path : path,
        rootPath : rootPath,
        virtualCurrentDirPath : virtualCurrentDirPath,
        allowIncludingChildren : sample.allowIncludingChildren,
      });
    }

    expected = sample.expected;

    executed.consequence.ifNoErrorThen( function( arg )
    {

      debugger;
      if( sample.usedFiles )
      {
        var used1 = _.entitySelect( executed.fileFrames,'*.file.relative' );
        var used2 = _.entitySelect( executed.fileFrames,'*.usedFiles.*.relative' );
        var usedFiles = {};
        for( var u = 0 ; u < used1.length ; u++ )
        {
          usedFiles[ used1[ u ] ] = used2[ u ];
        }
        logger.log( 'usedFiles',_.toJstruct( usedFiles ) );
        test.identical( usedFiles,sample.usedFiles );
      }

      if( sample.asyncFormatterCallCounter !== undefined )
      test.identical( _global_.asyncFormatterCallCounter , sample.asyncFormatterCallCounter );

      var got = context.fileProvider.filesTreeRead( checkPath );
      test.identical( got,expected );
      logger.log( 'filesTreeRead',checkPath );
      logger.log( _.toJson( got ) );

    });

    return executed.consequence;
  }

  /* */

  for( var s in context.samples ) (function()
  {
    var sample = context.samples[ s ];
    con.ifNoErrorThen( () => sampleTest( sample ) );
  })();

  return con;
}

samplesTest.timeOut = 90000;

// --
// proto
// --

var Self =
{

  name : 'wTools.FileExecutor',
  // verbosity : 7,

  context :
  {
    executorMakeFor : executorMakeFor,
    fileProvider : _.FileProvider.Default(),
    executor : null,
    dstPath : null,
    srcPath : null,
    samples : samples,
  },

  tests :
  {
    chunksSplit : chunksSplit,
    samplesTest : samplesTest,
  },

}

//

Self = wTestSuit( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
