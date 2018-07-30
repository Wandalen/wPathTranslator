( function _PathTranslator_s_() {

'use strict';

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

  _.include( 'wPath' );
  _.include( 'wCopyable' );

}

//

var _ = wTools;
var Parent = null;
var Self = function wPathTranslator( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
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

  path = _.pathsNormalize( path );
  path = _.pathsJoin( self.virtualCurrentDirPath,path );

  path = _.pathsReroot( self.realRootPath,path );

  path = _.pathsNormalize( path );

  return path;
}

//

function virtualFor( path )
{
  var self = this;

  path = _.pathsNormalize( path );
  path = _.pathsJoin( self.realCurrentDirPath,path );

  path = _.strReplaceBegin( path,self.realRootPath,'' );
  path = _.pathsJoin( '/',path );

  path = _.pathsNormalize( path );

  return path;
}

//

function virtualCurrentDirPathSet( path )
{
  var self = this;

  // debugger;
  path = _.pathNormalize( path );

  self[ virtualCurrentDirPathSymbol ] = path;

  if( !self.realRootPath )
  return;

  self[ realCurrentDirPathSymbol ] = self.realFor( path );

}

//

function realRootPathSet( path )
{
  var self = this;

  self[ realRootPathSymbol ] = _.pathNormalize( path );

  if( self.realCurrentDirPath )
  self.realCurrentDirPathSet( self.realCurrentDirPath );

}

//

function realCurrentDirPathSet( path )
{
  var self = this;

  path = _.pathNormalize( path );
  path = _.pathJoin( self.realRootPath,path );

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
// define class
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

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classMake
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
