( function _PathTranslator_s_() {

'use strict';

/**
  @module Tools/amid/PathTranslator - Simple class to map paths relative base path to make to make it appear that the root of files system is different.  Use PathTranslator to translate paths to virtual path namespace and vise verse.
*/

/**
 * @file PathTranslator.s.
 */

if( typeof module !== 'undefined' )
{

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

  _.include( 'wPathFundamentals'/*ttt*/ );
  _.include( 'wCopyable' );

}

//

var _ = wTools;
var Parent = null;
var Self = function wPathTranslator( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'PathTranslator';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.instanceInit( self );

  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

//

function realFor( path )
{
  var self = this;

  path = _.path.s.normalize( path );
  path = _.path.s.join( self.virtualCurrentDirPath,path );

  path = _.path.s.reroot( self.realRootPath,path );

  path = _.path.s.normalize( path );

  return path;
}

//

function virtualFor( path )
{
  var self = this;

  path = _.path.s.normalize( path );
  path = _.path.s.join( self.realCurrentDirPath,path );

  path = _.strReplaceBegin( path,self.realRootPath,'' );
  path = _.path.s.join( '/',path );

  path = _.path.s.normalize( path );

  return path;
}

//

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

//

function realRootPathSet( path )
{
  var self = this;

  self[ realRootPathSymbol ] = _.path.normalize( path );

  if( self.realCurrentDirPath )
  self.realCurrentDirPathSet( self.realCurrentDirPath );

}

//

function realCurrentDirPathSet( path )
{
  var self = this;

  path = _.path.normalize( path );
  path = _.path.join( self.realRootPath,path );

  if( !_.strBegins( path,self.realRootPath ) )
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

var Proto =
{

  init : init,

  realFor : realFor,
  virtualFor : virtualFor,

  virtualCurrentDirPathSet : virtualCurrentDirPathSet,
  realRootPathSet : realRootPathSet,
  realCurrentDirPathSet : realCurrentDirPathSet,

  /* relations */


  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

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
