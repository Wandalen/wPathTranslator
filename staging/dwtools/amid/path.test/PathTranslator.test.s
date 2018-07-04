( function _PathTranslator_test_s_( ) {

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

  require( '../path/PathTranslator.s' );

}

var _ = wTools;

// --
// tests
// --

function simple( test )
{
  var rooter = new wPathTranslator();
  rooter.realRootPath = '/a';

  test.description = 'realFor relative'; /* */

  var expected = '/a/x';
  var got = rooter.realFor( 'x' );
  test.identical( got,expected );

  test.description = 'realFor absolute'; /* */

  var expected = '/a/x';
  var got = rooter.realFor( '/x' );
  test.identical( got,expected );

  test.description = 'realFor relative root'; /* */

  var expected = '/a';
  var got = rooter.realFor( '.' );
  test.identical( got,expected );

  test.description = 'realFor absolute root'; /* */

  var expected = '/a';
  var got = rooter.realFor( '/' );
  test.identical( got,expected );

  test.description = 'virtualFor relative'; /* */

  var expected = '/x';
  var got = rooter.virtualFor( 'x' );
  test.identical( got,expected );

  test.description = 'virtualFor absolute'; /* */

  var expected = '/x';
  var got = rooter.virtualFor( '/a/x' );
  test.identical( got,expected );

  test.description = 'virtualFor absolute and redundant slashes'; /* */

  var expected = '/x';
  var got = rooter.virtualFor( '/a/x/' );
  test.identical( got,expected );

  test.description = 'virtualFor relative absolute'; /* */

  var expected = '/';
  var got = rooter.virtualFor( '.' );
  test.identical( got,expected );

}

//

function currentDir( test )
{
  var rooter = new wPathTranslator();

  test.identical( rooter.realCurrentDirPath,'/' );
  test.identical( rooter.virtualCurrentDirPath,'/' );

  rooter.realRootPath = '/a';

  test.identical( rooter.realCurrentDirPath,'/a' );
  test.identical( rooter.virtualCurrentDirPath,'/' );

  rooter.realCurrentDirPath = '/a/b/c';
  test.identical( rooter.realCurrentDirPath,'/a/b/c' );
  test.identical( rooter.virtualCurrentDirPath,'/b/c' );

  rooter.virtualCurrentDirPath = '/b';
  test.identical( rooter.realCurrentDirPath,'/a/b' );
  test.identical( rooter.virtualCurrentDirPath,'/b' );

  test.description = 'realFor relative'; /* */

  var expected = '/a/b/x';
  var got = rooter.realFor( 'x' );
  test.identical( got,expected );

  test.description = 'realFor absolute'; /* */

  var expected = '/a/x';
  var got = rooter.realFor( '/x' );
  test.identical( got,expected );

  test.description = 'realFor relative root'; /* */

  var expected = '/a/b';
  var got = rooter.realFor( '.' );
  test.identical( got,expected );

  test.description = 'realFor absolute root'; /* */

  var expected = '/a';
  var got = rooter.realFor( '/' );
  test.identical( got,expected );

  test.description = 'virtualFor relative'; /* */

  var expected = '/b/x';
  var got = rooter.virtualFor( 'x' );
  test.identical( got,expected );

  test.description = 'virtualFor absolute'; /* */

  var expected = '/b/x';
  var got = rooter.virtualFor( '/a/b/x' );
  test.identical( got,expected );

  test.description = 'virtualFor absolute and redundant slashes'; /* */

  var expected = '/b/x';
  var got = rooter.virtualFor( '/a/b/x/' );
  test.identical( got,expected );

  test.description = 'virtualFor relative absolute'; /* */

  var expected = '/b';
  debugger;
  var got = rooter.virtualFor( '.' );
  test.identical( got,expected );

  test.description = 'change realRootPath'; /* */

  var rooter = new wPathTranslator({ realRootPath : '/a' });
  test.identical( rooter.realCurrentDirPath,'/a' );
  test.identical( rooter.virtualCurrentDirPath,'/' );

  rooter.realRootPath = '/a/b/c';
  test.identical( rooter.realCurrentDirPath,'/a/b/c' );
  test.identical( rooter.virtualCurrentDirPath,'/' );

  test.description = 'change realRootPath sinking'; /* */

  var rooter = new wPathTranslator({ realRootPath : '/a' });
  rooter.realCurrentDirPath = '/a/b/c';
  test.identical( rooter.realCurrentDirPath,'/a/b/c' );
  test.identical( rooter.virtualCurrentDirPath,'/b/c' );

  rooter.realRootPath = '/a/b';
  test.identical( rooter.realCurrentDirPath,'/a/b/c' );
  test.identical( rooter.virtualCurrentDirPath,'/c' );

  rooter.realRootPath = '/a/b/c';
  test.identical( rooter.realCurrentDirPath,'/a/b/c' );
  test.identical( rooter.virtualCurrentDirPath,'/' );

  debugger;
  rooter.realRootPath = '/a/b/c/d';
  test.identical( rooter.realCurrentDirPath,'/a/b/c/d' );
  test.identical( rooter.virtualCurrentDirPath,'/' );

  test.description = 'change realCurrentDirPath relative'; /* */

  var rooter = new wPathTranslator({ realRootPath : '/a' });
  rooter.realCurrentDirPath = 'b/c';
  test.identical( rooter.realCurrentDirPath,'/a/b/c' );
  test.identical( rooter.virtualCurrentDirPath,'/b/c' );

}

//

function make( test )
{

  test.description = 'make with realCurrentDirPath'; /* */

  var rooter = new wPathTranslator({ realCurrentDirPath : _.pathRefine( __dirname ) });
  test.identical( rooter.realCurrentDirPath,_.pathRefine( __dirname ) );
  test.identical( rooter.virtualCurrentDirPath,_.pathRefine( __dirname ) );

}

// --
// define class
// --

var Self =
{

  name : 'Tools/mid/PathTranslator',
  // verbosity : 7,

  context :
  {
  },

  tests :
  {

    simple : simple,
    currentDir : currentDir,
    make : make,
  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

} )( );
