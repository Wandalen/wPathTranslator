( function _PathTranslator_s_()
{

'use strict';

/**
 * Simple class to map paths relative base path to make it appear that the root of files system is different.  Use PathTranslator to translate paths to virtual path namespace and vise verse.
  @module Tools/mid/PathTranslator
*/

if( typeof module !== 'undefined' )
{

  const _ = require( 'Tools' );

  _.include( 'wPathBasic' );
  _.include( 'wCopyable' );

}

//

/**
 * @classdesc Class to map paths relative base path to make it appear that the root of files system is different.
 * @param {Object} o Options map for constructor. {@link module:Tools/mid/PathTranslator.wPathTranslator.Fields Options description }
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.realFor( 'x' );// /a/x
 *
 * @class wPathTranslator
 * @namespace wTools
 * @module Tools/mid/PathTranslator
*/

const _ = _global_.wTools;
const Parent = null;
const Self = wPathTranslator;
function wPathTranslator( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'PathTranslator';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.workpiece.initFields( self );

  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

//

/**
 * @summary Translates virtual path to real.
 * @param {String} path Virtual path.
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.realFor( 'x' );// /a/x
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.realFor( '/x' );// /a/x
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.realFor( '.' );// /a
 *
 * @function realFor
 * @class wPathTranslator
 * @namespace wTools
 * @module Tools/mid/PathTranslator
*/

function realFor( path )
{
  var self = this;

  path = _.path.s.normalize( path );
  path = _.path.s.join( self.virtualCurrentDirPath, path );

  path = _.path.s.reroot( self.realRootPath, path );

  path = _.path.s.normalize( path );

  return path;
}

//

/**
 * @summary Translates real path to virtual.
 * @param {String} path Real path.
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.virtualFor( '/x' );// "/x"
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.virtualFor( '/a/x' );// "/x"
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.virtualFor( '.' );// "/"
 *
 * @function virtualFor
 * @class wPathTranslator
 * @namespace wTools
 * @module Tools/mid/PathTranslator
*/

function virtualFor( path )
{
  var self = this;

  path = _.path.s.normalize( path );
  path = _.path.s.join( self.realCurrentDirPath, path );

  path = _.strReplaceBegin( path, self.realRootPath, '' );
  path = _.path.s.join( '/', path );

  path = _.path.s.normalize( path );

  return path;
}

//

/**
 * @summary Changes current directory for virtual paths.
 * @param {String} path New path.
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.virtualCurrentDirPathSet( '/b' );
 * rooter.realFor( 'c' )// "/a/b/c"
 *
 * @function virtualCurrentDirPathSet
 * @class wPathTranslator
 * @namespace wTools
 * @module Tools/mid/PathTranslator
*/

function virtualCurrentDirPathSet( path )
{
  var self = this;

  // debugger;
  path = _.path.normalize( path );

  self[ virtualCurrentDirPathSymbol ] = path;

  if( !self.realRootPath )
  return;

  self[ realCurrentDirPathSymbol ] = self.realFor( path );

}

/**
 * @summary Changes root path for real paths.
 * @description Updates path of current directory for real paths.
 * @param {String} path New path.
 *
 * @example
 * var rooter = new wPathTranslator();
 * rooter.realRootPathSet( '/a' );
 * rooter.realFor( 'c' )// "/a/c"
 *
 * @function realRootPathSet
 * @class wPathTranslator
 * @namespace wTools
 * @module Tools/mid/PathTranslator
*/

//

function realRootPathSet( path )
{
  var self = this;

  self[ realRootPathSymbol ] = _.path.normalize( path );

  if( self.realCurrentDirPath )
  self.realCurrentDirPathSet( self.realCurrentDirPath );

}

//

/**
 * @summary Changes current directory for reals paths.
 * @description Updates path of current directory for both types of paths.
 * @param {String} path New path.
 *
 * @example
 * var rooter = new wPathTranslator({ realRootPath : '/a' });
 * rooter.realCurrentDirPathSet( 'b' );
 * rooter.virtualFor( 'c' )// "/b/c"
 *
 * @function realCurrentDirPathSet
 * @class wPathTranslator
 * @namespace wTools
 * @module Tools/mid/PathTranslator
*/

function realCurrentDirPathSet( path )
{
  var self = this;

  path = _.path.normalize( path );
  path = _.path.join( self.realRootPath, path );

  if( !_.strBegins( path, self.realRootPath ) )
  path = self.realRootPath;

  self[ realCurrentDirPathSymbol ] = path;
  self[ virtualCurrentDirPathSymbol ] = self.virtualFor( path );

}

// --
// var
// --

var virtualCurrentDirPathSymbol = Symbol.for( 'virtualCurrentDirPath' );
var realRootPathSymbol = Symbol.for( 'realRootPath' );
var realCurrentDirPathSymbol = Symbol.for( 'realCurrentDirPath' );

/**
 * @typedef {Object} Fields
 * @property {String} virtualCurrentDirPath='/' Current directory for virtual paths.
 * @property {String} realRootPath='/' Root path for real path.
 * @property {String} realCurrentDirPath='/' Current directory for real paths.
 * @module Tools/mid/PathTranslator
 */

// --
// relations
// --

var Composes =
{

  virtualCurrentDirPath : '/',
  realRootPath : '/',
  realCurrentDirPath : '/',

}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

var Statics =
{
}

var Forbids =
{
  virtualCurrentDir : 'virtualCurrentDir',
  realCurrentDir : 'realCurrentDir',
}

var Accessors =
{
  virtualCurrentDirPath : 'virtualCurrentDirPath',
  realRootPath : 'realRootPath',
  realCurrentDirPath : 'realCurrentDirPath',
}

// --
// declare
// --

const Proto =
{

  init,

  realFor,
  virtualFor,

  virtualCurrentDirPathSet,
  realRootPathSet,
  realCurrentDirPathSet,

  /* relations */


  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

wCopyable.mixin( Self );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
_global_[ Self.name ] = wTools[ Self.shortName ] = Self;

})();
