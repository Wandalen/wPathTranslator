( function _FileExecutor_s_() {

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

  _.include( 'wFiles' );
  _.include( 'wFilesArchive' );
  _.include( 'wEventHandler' );
  _.include( 'wConsequence' );

  require( './PathTranslator.s' );

  var VirtualMachine = require( 'vm' );
  var Coffee = require( 'coffee-script' );

}

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFileExecutor( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileExecutor';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.instanceInit( self );

  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( self.archive === null )
  self.archive = new _.FilesArchive();

  if( self.fileProvider === null )
  self.fileProvider = new _.FileFilter.Archive({ archive : self.archive });

  // if( self.fileProvider === null )
  // self.fileProvider = new _.FileProvider.Default();

  return self;
}

//

function languageFromFilePath( filePath )
{

  if( _.strEnds( filePath,'.coffee' ) )
  return 'coffee'
  else if( _.strEnds( filePath,'.js' ) || _.strEnds( filePath,'.s' ) || _.strEnds( filePath,'.ss' ) )
  return 'ecma';

}

//

function scriptExecute( o )
{

  _.assert( arguments.length === 1 );
  _.routineOptions( scriptExecute,o );

  if( !o.language )
  o.language = languageFromFilePath( o.filePath );
  if( !o.name )
  o.name = _.pathName( o.filePath );

  if( !o.language && o.defaultLanguage )
  o.language = o.defaultLanguage;

  if( o.language === 'ecma' )
  return this.ecmaExecute( o );
  else if( o.language === 'coffee' )
  return this.coffeeExecute( o );

  _.assert( 0,'unknown language',o.language );
}

scriptExecute.defaults =
{
  language : null,
  defaultLanguage : null,
  code : null,
  filePath : null,
  name : null,
  context : null,
  isConfig : 0,
  // wrapContext : 1,
  // return : 0,
  externals : null,
  verbosity : 1,
  debug : 0,
}

//

function ecmaExecute( o )
{
  var result;

  _.routineOptions( ecmaExecute,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.code ) );

  var execOptions =
  {
    code : o.code,
    context : o.context,
    filePath : o.filePath,
    prependingReturn : o.prependingReturn,
    externals : o.externals,
    debug : o.debug,
  }

  _.routineExec( execOptions );
  _.mapExtend( o,execOptions );

  return o;
}

ecmaExecute.defaults =
{

  prependingReturn : 0,

  // code : null,
  // context : null,

  language : 'ecma',

  // executor : null,
  //
  // language : 'coffee',
  // filePath : null,
  // name : null,
  // return : 1,
  //
  // codePrefix : null,
  // codePostfix : null,
  // onInclude : null,
  // externals : null,
  //
  // bare : 1,
  // fix : 1,
  // wrapContext : 0,
  // verbosity : 1,

  // context : {},
  // executor : null,
  //
  // language : 'coffee',
  // filePath : null,
  // name : null,
  // return : 1,
  //
  // codePrefix : null,
  // codePostfix : null,
  // onInclude : null,
  // externals : null,
  //
  // bare : 1,
  // fix : 1,
  // wrapContext : 0,
  // verbosity : 1,

}

ecmaExecute.defaults.__proto__ = scriptExecute.defaults;

//

function coffeeCompile( o )
{
  var self = this;
  var result = '';

  _.assert( arguments.length === 1 );
  _.routineOptions( coffeeCompile,o );

  if( !_.strIs( o.code ) )
  throw _.err( 'coffeCompile','expects (-o.code-)' );

  // if( o.fix )
  // {
  //   o.code = _.strIndentation( o.code,'  ' );
  //   o.code = [ self.prefix, o.code, self.postfix ].join( '\n' );
  // }

  var compileOptions =
  {
    filename : o.filePath,
    bare : !!o.baring,
  }

  result += Coffee.compile( o.code,compileOptions );

  return result;
}

coffeeCompile.defaults =
{
  filePath : null,
  code : null,
  baring : 0,
}

//

function coffeeExecute( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { code : code };

  _.routineOptions( coffeeExecute,o );
  _.assert( arguments.length === 1 );

  if( !o.name )
  o.name = o.filePath ? _.pathName( o.filePath ) : 'unknown';

  var optionsForCompile = _.mapExtend( null,o );
  o.filePath = self.fileProvider.pathNativize( o.filePath );

  logger.log( 'coffeeExecute',o.filePath );
  // if( o.filePath.indexOf( 'electron' ) !== -1 )
  // debugger;

  // o.code = this.coffeeCompile( o );
  var optionsForCompile = _.mapScreen( this.coffeeCompile.defaults,o );
  optionsForCompile.baring = o.isConfig;
  o.code = this.coffeeCompile( optionsForCompile );
  // o.code = _.routineTolerantCall( this, this.coffeeCompile , o );
  o.prependingReturn = 1;

  var result = this.ecmaExecute( o );
  // debugger;

  return result;
}

coffeeExecute.defaults =
{
  language : 'coffee',
}

// _.mapSupplement( coffeeExecute.defaults,coffeeCompile.defaults );

coffeeExecute.defaults.__proto__ = scriptExecute.defaults;

// --
// include
// --


function sessionMake( o )
{
  var self = this;

  _.routineOptions( sessionMake,o );
  _.assert( arguments.length === 1 );

  var session = Object.create( null );
  session.rootIncludeFrame = null;
  session.fileFrames = [];
  session.onFileExec = null;

  _.mapExtend( session,o );

  if( session.exposingInclude || session.exposingEnvironment || session.exposingTools )
  {
    session.externals = session.externals || Object.create( null );
  }

  Object.preventExtensions( session );
  return session;
}

sessionMake.defaults =
{
  allowIncluding : 1,
  allowIncludingChildren : 1,
  exposingInclude : 1,
  exposingEnvironment : 1,
  exposingTools : 1,
  externals : null,
  context : null,
}

//

function includeFrameBegin( o )
{
  var self = this;

  _.routineOptions( includeFrameBegin,o );
  _.assert( arguments.length === 1 );

  var includeFrame = IncludeFrame.constructor();

  includeFrame.userIncludeFrame = o.userIncludeFrame;
  includeFrame.fileFrames = [];

  includeFrame.session = includeFrame.userIncludeFrame ? includeFrame.userIncludeFrame.session : self.session;
  includeFrame.externals = includeFrame.session.externals;
  includeFrame.context = includeFrame.session.context;

  if( !includeFrame.userIncludeFrame )
  {
    self.session.rootIncludeFrame = includeFrame;
  }

  Object.preventExtensions( includeFrame );
  self.includeFrames.unshift( includeFrame );

  return includeFrame;
}

includeFrameBegin.defaults =
{
  userIncludeFrame : null,
}

//

function includeFrameEnd( includeFrame )
{
  var self = this;

  if( self.verbosity > 1 )
  logger.log( 'includeFrameEnd',includeFrame.includeOptions.path );

  _.assert( arguments.length === 1 );
  _.assert( includeFrame.session === self.session );
  _.assert( _.construction.isLike( includeFrame,IncludeFrame ) );

  _.arrayRemoveOnceStrictly( self.includeFrames,includeFrame );

  if( !includeFrame.userIncludeFrame )
  {
    self.session = null;
    _.assert( self.includeFrames.length === 0 );
  }

}

//

function _includeAct( o )
{
  var self = this;
  var session = o.session;

  _.routineOptions( _includeAct,o );
  _.assert( arguments.length === 1 );
  _.assert( session );
  _.assert( o.pathTranslator );

  // debugger;

  if( self.verbosity > 2 )
  logger.log( '_includeAct.begin',o.path );

  // var maskTerminal = new _.RegexpObject( rdescriptor.includeMask,_.RegexpObject.Names.includeAny );
  var maskTerminal = new _.RegexpObject( [],_.RegexpObject.Names.includeAny );
  // _.RegexpObject.shrink( maskTerminal,_.pathRegexpMakeSafe() );
  var maskTerminal2 = _.regexpMakeObject
  ({
    excludeAny :
    [
      /(^|\/)\.(?!$|\/|\.)/,
      /(^|\/)-/,
    ],
  });

  maskTerminal = _.RegexpObject.shrink( maskTerminal,maskTerminal2 );

  // debugger;
  // console.log( '_includeAct',o.path,_.pathIsGlob( o.path ) );
  if( !o.withManual && _.pathIsGlob( o.path ) )
  {
    _.RegexpObject.shrink( maskTerminal,wRegexpObject({ excludeAny : /\.(manual)($|\.|\/)/ }) );
  }

  // if( options.forTheDocument )
  // {
  //   var maskNotManual = _.regexpMakeObject( self.env.valueGet( '{{mask.manual}}' ) || /\.manual($|\.|\/)/,_.RegexpObject.Names.excludeAny );
  //   _.RegexpObject.shrink( maskTerminal,maskNotManual );
  // }
  //
  // if( options.maskTerminal )
  // _.RegexpObject.shrink( maskTerminal,_.regexpMakeObject( options.maskTerminal,_.RegexpObject.Names.includeAny ) );

  var userIncludeFrame = self.includeFrames[ 0 ];
  var includeFrame = self.includeFrameBegin({ userIncludeFrame : userIncludeFrame });

  _.assert( _.construction.isLike( includeFrame,IncludeFrame ) );

  includeFrame.userChunkFrame = o.userChunkFrame;
  includeFrame.pathTranslator = o.pathTranslator.clone();
  includeFrame.includeOptions = o;
  includeFrame.resolveOptions = o.resolveOptions || Object.create( null );

  // logger.log( 'maskTerminal',_.toStr( maskTerminal,{ levels : 3 } ) );

  /* resolve */

  var resolveOptions =
  {
    globPath2 : includeFrame.pathTranslator.virtualFor( o.path || '.' ),
    ends : o.ends,
    pathTranslator : includeFrame.pathTranslator,
    maskTerminal : maskTerminal,
    outputFormat : 'record',
    orderingExclusion : [ [ '.external','' ], [ '.pre', '', '.post' ] ],
  }

  includeFrame.resolveOptions
  =
  self.fileProvider._filesFindMasksSupplement( includeFrame.resolveOptions,resolveOptions );

  // console.log( 'resolveOptions.globPath2',resolveOptions.globPath2 );
  // if( resolveOptions.globPath2 === '/common.external/Underscore.js' )
  // debugger;
  // debugger;
  includeFrame.files = self.fileProvider.filesResolve2( includeFrame.resolveOptions );
  // debugger;

  if( !includeFrame.files.length && !o.optional )
  {
    debugger;
    throw _.err( '\nnone file found for',includeFrame.resolveOptions.globPath2,'\n' );
  }

  /* */

  // debugger;
  if( !o.syncExternal )
  o.syncExternal = new _.Consequence().give();
  includeFrame.consequence = new _.Consequence();

  o.syncExternal.got( function( err,arg )
  {
    includeFrame.consequence.give( err,arg );
  });

  self.filesExecute
  ({
    includeFrame : includeFrame,
    consequence : includeFrame.consequence,
  })

  includeFrame.consequence.ifNoErrorThen( function _includeSecondAfter( arg )
  {
    if( self.verbosity > 2 )
    logger.log( '_includeAct.end',o.path );
    _.assert( session === self.session );
    return arg;
  });

  includeFrame.consequence.doThen( function _includeSecondAfter( err,arg )
  {

    if( err )
    {
      o.syncExternal.give( err,arg );
      throw _.err( err );
    }

    // logger.log( 'includeFrameEnd\n',_.entitySelect( self.includeFrames,'*.includeOptions.globPath2' ) );

    self.includeFrameEnd( includeFrame );

    o.syncExternal.give();
    return arg;
  });

  return includeFrame;
}

_includeAct.defaults =
{
  path : null,
  ends : null,
  optional : 0,
  withManual : 0,
  ifAny : null,
  ifAll : null,
  ifNone : null,
  onIncludeFromat : null,
  session : null,
  pathTranslator : null,
  userChunkFrame : null,
  resolveOptions : null,
  syncExternal : null,
}

//

function _includeFromChunk( bound,o,o2 )
{
  var self = this;
  var chunkFrame = bound.chunkFrame;
  var include = bound.include;
  var session = chunkFrame.fileFrame.includeFrame.session;

  if( _.strIs( o ) )
  o = { path : o };

  if( _.routineIs( o2 ) )
  o2 = { onIncludeFromat : o2 }

  if( o2 )
  {
    _.mapExtend( o,o2 );
  }

  _.assertMapHasOnly( include,_includeFromChunk.parameters );
  var o3 = _.mapScreen( _includeFromChunk.defaults,include );

  _.mapSupplement( o,o3 );

  o.session = session;
  o.pathTranslator = chunkFrame.fileFrame.pathTranslator;
  o.syncExternal = chunkFrame.syncExternal;
  o.userChunkFrame = chunkFrame;

  var included = self._includeAct( o );

  _.assert( _.consequenceIs( o.syncExternal ) );
  _.assert( o2 === undefined || _.objectIs( o2 ) );
  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( o.pathTranslator );
  _.assert( session );
  _.assert( _.construction.isLike( included,IncludeFrame ) );

  // included.consequence.got( function( err,arg )
  // {
  //   this.give( err,arg );
  // });

  _.assert( included.files.length === included.fileFrames.length );

  if( self.verbosity > 4 )
  {
    logger.log( 'includeFromChunk.includeFrame :',chunkFrame.fileFrame.includeFrame.includeOptions.path );
    logger.log( 'includeFromChunk.fileFrame :',chunkFrame.fileFrame.file.relative );
  }

  chunkFrame.usedIncludeFrames.push( included );
  chunkFrame.fileFrame.usedIncludeFrames.push( included );
  chunkFrame.fileFrame.includeFrame.usedIncludeFrames.push( included );

  return '';
}

_includeFromChunk.defaults =
{
}

_includeFromChunk.defaults.__proto__ = _includeAct.defaults;

_includeFromChunk.parameters =
{
}

_includeFromChunk.parameters.__proto__ = _includeAct.defaults;

//

function include( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { path : o };

  if( self.verbosity > 1 )
  logger.log( 'include',o.path );

  _.routineOptions( include,o );
  _.assert( arguments.length === 1 );
  _.assert( self.session === null,'attempt to relaunch executor during execution' );

  if( !o.pathTranslator )
  {
    o.pathTranslator = self.pathTranslator.clone();
    var realRootPath = _.strIs( o.path ) ? _.pathDir( o.path ) : _.pathCommon( o.path );
    o.pathTranslator.realRootPath = realRootPath;
  }

  if( o.rootPath )
  {
    o.pathTranslator.realRootPath = o.rootPath;
  }

  if( o.virtualCurrentDirPath )
  {
    o.pathTranslator.virtualCurrentDirPath = o.virtualCurrentDirPath;
  }

  if( !o.session )
  o.session = self.sessionMake( _.mapScreen( self.sessionMake.defaults, o ) );
  self.session = o.session;
  // debugger;

  /* */

  var includeFrame = self._includeAct( _.mapScreen( self._includeAct.defaults, o ) );

  /* */

  includeFrame.consequence.doThen( function _includeAfter( err,arg )
  {
    if( err )
    {
      debugger;
      err = _.err( 'Error including',o.path,'\n',err );
      throw _.errLogOnce( err );
    }

    _.assert( self.session === null )
    _.assert( self.includeFrames.length === 0 );

    return arg;
  });

  return includeFrame;
}

include.defaults =
{
  rootPath : null,
  virtualCurrentDirPath : null,
}

_.mapExtend( include.defaults , sessionMake.defaults );
_.mapExtend( include.defaults , _includeAct.defaults );

// --
// file
// --

function filesExecute( o )
{
  var self = this;
  if( !o.consequence )
  o.consequence = new _.Consequence().give();
  var con = o.consequence;
  var session = o.includeFrame.session;
  var files = o.includeFrame.files;

  _.routineOptions( filesExecute,o );
  _.assert( arguments.length === 1 );
  _.assert( _.construction.isLike( o.includeFrame,IncludeFrame ) );
  _.assert( o.includeFrame );
  _.assert( o.includeFrame.files );
  _.assert( session );

  /* prepare */

  for( var i = 0 ; i < files.length ; i += 1 )
  {
    var file = files[ i ];
    self.fileFrameFor
    ({
      file : file,
      includeFrame : o.includeFrame,
    });
  }

  /* filter out */

  self.filesFilter( o.includeFrame );

  _.assert( o.includeFrame.files.length === o.includeFrame.fileFrames.length );

  if( !session.allowIncludingChildren )
  session.allowIncluding = 0;

  /* execute */

  for( var i = 0 ; i < files.length ; i += 1 )
  {
    var file = files[ i ];
    con.ifNoErrorThen( _.routineSeal( self,self.fileExecute,[{ file : file, includeFrame : o.includeFrame }] ) );
  }

  // con.got( function( err,arg ) {
  //   debugger;
  //   this.give( err,arg );
  // });

  return con;
}

filesExecute.defaults =
{
  includeFrame : null,
  consequence : null,
}

//

function fileExecute( o )
{
  var self = this;
  var file = o.file;
  var includeFrame = o.includeFrame;
  var session = includeFrame.session;

  var fileFrame = self.fileFrameFor
  ({
    file : file,
    includeFrame : includeFrame,
  });

  _.assert( fileFrame.includeFrames.indexOf( includeFrame ) !== -1,'expects same includeFrame' );
  _.routineOptions( fileExecute,o );
  _.assert( arguments.length === 1 );
  _.assert( session );
  _.assert( _.construction.isLike( fileFrame,FileFrame ) );

  if( !file.stat )
  debugger;

  if( file.stat.size > o.maxSize )
  {
    logger.warn( 'WARNING :','execution of file ( ',file.stat.size,'>',o.maxSize,' ) canceled because it is too big :',file.absolute );
    return;
  }

  if( fileFrame.executing )
  {
    throw _.err( 'File',fileFrame.file.absolute,'already executing, recursion dependence!' );
  }

  if( fileFrame.executed )
  {
    if( self.verbosity > 1 )
    logger.log( 'already executed :',fileFrame.file.relative );
    self.includesUsedInherit( includeFrame,fileFrame );
    return fileFrame.consequence;
  }

  /* fileFrame.includeFrame should point on include frame in which fileFrame was executed */

  fileFrame.includeFrame = includeFrame;

  _.assert( !fileFrame.executed );
  _.assert( !fileFrame.executing );
  _.assert( !fileFrame.consequence );
  _.assert( !fileFrame.result );

  /* verbosity */

  if( self.verbosity )
  logger.log( 'fileExecute',o.file.absolute );

  if( self.warnBigFiles )
  if( file.stat.size > self.warnBigFiles )
  logger.warn( 'WARNING :','execution of big (',file.stat.size,'>',self.warnBigFiles,') files is slow :',file.absolute );

  /* */

  fileFrame.executed = 0;
  fileFrame.executing = 1;

  self._fileExecute( fileFrame );

  /* write */

  fileFrame.consequence.ifNoErrorThen( function( arg )
  {

    if( self.verbosity > 1 )
    logger.log( 'fileExecute.end1',file.absolute );

    _.assert( _.strIs( arg ) || fileFrame.error,'problem executing file',fileFrame.file.absolute );
    _.assert( _.strIs( fileFrame.result ),'problem executing file',fileFrame.file.absolute );

    fileFrame.usedFiles = self.filesUsedGet( fileFrame.usedIncludeFrames );

    return arg;
  });

  /* */

  fileFrame.consequence.doThen( function _fileExecuteAfter( err,arg )
  {

    if( err )
    fileFrame.error = err;

    if( fileFrame.error )
    {

      throw _.err( fileFrame.error );

    }
    else
    {

      if( fileFrame.chunks.length !== 0 )
      if( fileFrame.chunks.length !== 1 || fileFrame.chunks[ 0 ].code !== undefined )
      {

        // if( fileFrame.usedFiles.length )
        // self.archive.dependencyAdd( file,fileFrame.usedFiles );
        //
        // self.archive.contentUpdate( file,fileFrame.result );

        self.fileProvider.fileWrite
        ({
          filePath : file.absolute,
          data : fileFrame.result,
          sync : 1,
          purging : 1,
        });

        // file.restat();
        // self.archive.statUpdate( file,file.stat );

        if( self.verbosity )
        logger.log( '+ executed :',file.absolute );

      }

    }

    fileFrame.executed = 1;
    fileFrame.executing = 0;

    // if( self.verbosity > 1 )
    // logger.log( 'fileExecute.end2',file.absolute );

    return fileFrame.result;
  });

  /* */

  return fileFrame.consequence;
}

fileExecute.defaults =
{
  includeFrame : null,
  file : null,
}

//

function _fileExecute( o )
{
  var self = this;
  var session = o.session;
  var includeFrame = o.includeFrame;

  if( _.strIs( o ) )
  o = { code : o }

  _.assert( arguments.length === 1 );
  _.assert( o.file instanceof _.FileRecord );
  _.assert( _.construction.isLike( o,FileFrame ) );
  _.assert( !o.consequence );

  /* result */

  o.result = '';
  if( !o.consequence )
  o.consequence = new _.Consequence().give();

  /* var */

  var errorPrefix = '';
  if( o.file )
  errorPrefix = _.str( o.file.absolute + ' :', '\n' );

  /* read file */

  try
  {

    if( o.code === null || o.code === undefined )
    o.code = self.fileProvider.fileReadSync( o.file.absolute );

  }
  catch( err )
  {
    o.error = _.err( 'Cant read file :', o.file.absolute, '\n', err );
    return o;
  }

  /* chunks */

  var chunks = self._chunksSplit( o.code,_.mapScreen( _chunksSplit.defaults,o ) );
  if( chunks.error )
  o.error = _.err( errorPrefix,chunks.error,'\n' );
  o.chunks = chunks.chunks;

  if( !chunks.error )
  for( var c = 0 ; c < o.chunks.length ; c++ ) (function _executeChunk()
  {

    var chunk = o.chunks[ c ];
    _.assert( _.numberIs( chunk.index ) );
    Object.preventExtensions( chunk );

    var optionsChunkExecute = Object.create( null );
    optionsChunkExecute.fileFrame = o;
    optionsChunkExecute.chunk = chunk;
    o.consequence.ifNoErrorThen( _.routineSeal( self,self.chunkExecute,[ optionsChunkExecute ] ) );
    o.consequence.ifNoErrorThen( function( arg )
    {
      _.assert( _.strIs( arg ) );
      o.result += arg;
      return arg;
    });

  })();

  /* return */

  return o;
}

//

function filesFilter( includeFrame )
{
  var self = this;
  var io = includeFrame.includeOptions;

  _.assert( arguments.length === 1 );
  _.assert( _.construction.isLike( includeFrame,IncludeFrame ) );

  if( !io.ifAny && !io.ifAll && !io.ifNone )
  return;

  if( _.strIs( io.ifAny ) )
  io.ifAny = [ io.ifAny ];
  if( _.strIs( io.ifAll ) )
  io.ifAll = [ io.ifAll ];
  if( _.strIs( io.ifNone ) )
  io.ifNone = [ io.ifNone ];

  var fileFrames = includeFrame.fileFrames;
  var files = includeFrame.files;
  for( var f = fileFrames.length-1 ; f >= 0 ; f-- )
  {
    var fileFrame = fileFrames[ f ];

    if( io.ifAny )
    if( !_.arrayHasAny( fileFrame.categories,io.ifAny ) )
    {
      fileFrames.splice( f,1 );
      files.splice( f,1 );
      continue;
    }

    if( io.ifAll )
    if( !_.arrayHasAll( fileFrame.categories,io.ifAll ) )
    {
      fileFrames.splice( f,1 );
      files.splice( f,1 );
      continue;
    }

    if( io.ifNone )
    if( !_.arrayHasNone( fileFrame.categories,io.ifNone ) )
    {
      fileFrames.splice( f,1 );
      files.splice( f,1 );
      continue;
    }

  }

}

//

function fileFrameFor( fileFrame )
{
  var self = this;
  var includeFrame = fileFrame.includeFrame;
  var session = includeFrame.session;

  // if( !fileFrame.session )
  // {
  //   debugger;
  //   fileFrame.session = includeFrame
  // }

  _.assert( arguments.length === 1 );
  _.assert( session );
  _.assert( includeFrame );

  if( self.verbosity > 4 )
  logger.log( 'fileFrameFor',fileFrame.file.absolute );

  var equ = ( e ) => e.file.absolute;
  var fileFrameFound = _.arrayLeft( session.fileFrames , fileFrame.file.absolute , equ ).element;
  if( fileFrameFound )
  {
    _.arrayAppendOnce( fileFrameFound.includeFrames , includeFrame );
    _.arrayAppendOnce( includeFrame.fileFrames , fileFrameFound );
    return fileFrameFound;
  }

  /* */

  fileFrame = FileFrame.constructor( fileFrame );

  if( !session.allowIncluding )
  throw _.err( 'can only reuse included files, but was attempt to include a new one',fileFrame.file.absolute );

  includeFrame.fileFrames.push( fileFrame );
  session.fileFrames.push( fileFrame );

  fileFrame.includeFrames.push( includeFrame );
  fileFrame.pathTranslator = includeFrame.pathTranslator.clone();
  fileFrame.pathTranslator.realCurrentDirPath = fileFrame.file.dir;

  if( fileFrame.context === null )
  fileFrame.context = includeFrame.context;

  if( fileFrame.externals === null )
  fileFrame.externals = _.mapExtend( null,includeFrame.externals );

  fileFrame.categories = self.categoriesForFile( fileFrame );

  return fileFrame;
}

// --
// chunk
// --

function chunkFrameFor( o )
{
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );
  o = ChunkFrame.constructor( o );
  return o;
}

//

function chunkExecute( o )
{
  var self = this;
  var includeFrame = o.fileFrame.includeFrame;

  // _.assert( arguments.length === 1 );
  o = chunkFrameFor( o );

  if( self.verbosity > 2 )
  logger.log( 'chunkExecute',o.fileFrame.file.relative,o.chunk.index );

  /* */

  o.syncInternal = new wConsequence({ limitNumberOfMessages : 1 });
  o.syncExternal = new wConsequence({ limitNumberOfMessages : 1 }).give();

  var executed = self._chunkExecute( o );
  executed = wConsequence.from( executed );

  executed.got( function( err,arg )
  {

    if( self.verbosity > 2 )
    logger.log( 'chunkExecute.end1',o.fileFrame.file.relative,o.chunk.index );

    if( err )
    return this.give( err,arg );

    if( _.numberIs( arg ) )
    arg = _.toStr( arg );

    if( !_.strIs( arg ) )
    return this.error( _.err
    (
      'chunk should return string, but returned',_.strTypeOf( arg ),
      '\ncode :\n',_.strLinesNumber( o.chunk.text || o.chunk.code )
    ));

    this.give( err,arg );
  });

  executed.andThen( o.syncExternal );
  executed.doThen( o.syncInternal );

  /* */

  // o.syncInternal.got( function( err,arg )
  // {
  //   debugger;
  //   this.give( err,arg );
  // });

  o.syncInternal.ifNoErrorThen( function chunkExecuteAfter( result )
  {

    _.assert( result.length === 2 );
    result = result[ 1 ];

    if( self.verbosity > 2 )
    logger.log( 'chunkExecute.end2',o.fileFrame.file.relative,o.chunk.index );

    _.assert( _.strIs( result ),'expects string result from chunk' );
    _.assert( _.arrayIs( o.usedIncludeFrames ) );

    o.resultRaw = result;
    o.result = result;

    // debugger;
    return self._chunkConcat( o );
  });

  /* */

  o.syncInternal.ifNoErrorThen( function( arg )
  {

    if( self.verbosity > 2 )
    logger.log( 'chunkExecute.end3',o.fileFrame.file.relative,o.chunk.index );

    _.assert( _.strIs( arg ) );
    _.assert( _.strIs( o.result ) );
    self._chunkTabulate( o );

    return o.result;
  });

  return o.syncInternal;
}

//

function _chunkExecute( o )
{
  var self = this;
  var session = o.fileFrame.includeFrame.session;

  _.assert( session );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.chunk.text ) || _.strIs( o.chunk.code ) );
  _.assert( _.construction.isLike( o,ChunkFrame ) );

  /* */

  if( _.strIs( o.chunk.text ) )
  {
    return o.chunk.text;
  }
  else if( _.strIs( o.chunk.code ) ) try
  {

    /* exposing */

    if( !o.externals && o.fileFrame.externals )
    o.externals = _.mapExtend( null,o.fileFrame.externals );
    self._chunkExpose( o );

    /* */

    var execution = _.mapScreen( ecmaExecute.defaults,o );
    execution.language = self.languageFromFilePath( o.fileFrame.file.absolute );
    execution.filePath = o.fileFrame.file.absolute + '{' + o.chunk.line + '-' + ( o.chunk.line + o.chunk.lines.length ) + '}';

    execution.verbosity = self.verbosity;
    execution.debug = self.debug;

    execution.context = o.fileFrame.context;
    execution.externals = o.externals;
    execution.defaultLanguage = 'ecma';

    // if( execution.externals )
    // execution.externals = _.mapExtend( null,execution.externals );
    // for( var ex in execution.externals )
    // execution.externals[ ex ] = _.routineJoin( o.fileFrame.context,execution.externals[ ex ] );

    execution.code = o.chunk.code;
    o.execution = execution;

    // debugger;
    self.scriptExecute( execution );

    // _.assert( _.strIs( execution.result ) );
    // if( !_.strIs( execution.result ) )
    // debugger;

    return execution.result;
  }
  catch( err )
  {

    debugger;
    throw _.err
    (
      'Error executing chunk :\n',_.toStr( o.chunk ), '\n',
      '\nat file',o.fileFrame.file.absolute,
      '\n',err
    );

  }

}

// _chunkExecute.defaults = chunkExecute.defaults;

//

function _chunkExpose( chunkFrame )
{
  var self = this;
  var externals = chunkFrame.externals;
  var fileFrame = chunkFrame.fileFrame;
  var file = fileFrame.file;
  var session = fileFrame.includeFrame.session;

  _.assert( arguments.length === 1 );
  _.assert( _.construction.isLike( chunkFrame,ChunkFrame ) );

  /* exposing */

  if( session.exposingInclude )
  {

    _.assert( externals.include === undefined );
    var bound = Object.create( null );
    externals.include = _.routineJoin( self,self._includeFromChunk,[ bound ] );
    bound.chunkFrame = chunkFrame;
    bound.include = externals.include;

  }

  if( session.exposingEnvironment )
  {

    _.assert( externals.__filename === undefined );
    _.assert( externals.__dirname === undefined );
    _.assert( externals.__file === undefined );
    _.assert( externals.__fileFrame === undefined );
    _.assert( externals.__chunkFrame === undefined );

    externals.__filename = file.absolute;
    externals.__dirname = file.dir;
    externals.__file = file;
    externals.__chunkFrame = chunkFrame;
    externals.__fileFrame = fileFrame;
    externals.__templateExecutor = self;

  }

  if( session.exposingTools )
  {

    _.assert( externals._ === undefined || externals._ === wTools );
    _.assert( externals.wTools === undefined || externals.wTools === wTools );

    externals._ = _global_.wTools;
    externals.wTools = wTools;

  }

}

//

function _chunkTabulate( chunkFrame )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( chunkFrame.chunk.kind !== 'dynamic' )
  return;

  var result = '';
  var ret = '';

  if( _.strIs( chunkFrame.result ) )
  ret = chunkFrame.result;
  else
  ret = _.toStr( chunkFrame.result );

  ret = ret.split( '\n' );

  if( ret[ ret.length-1 ].trim() === '' )
  ret.splice( ret.length-1,1 );

  for( var r = 0, l = ret.length ; r < l ; r++ )
  {
    var prefix = r > 0 ? chunkFrame.chunk.tab : '';
    var postfix = r < l-1 ? '\n' : '';
    result += prefix + ret[ r ] + postfix;
  }

  chunkFrame.result = result;
}

//

function _chunksSplit( src,o )
{

  return _.strSplitChunks( src,o );

}

_chunksSplit.defaults = _.strSplitChunks.defaults;

//

function _chunkConcat( chunkFrame )
{
  var self = this;
  var result = [];
  var err = null;
  var con = new _.Consequence();
  var chunkFormatterOptions = Object.create( null );

  _.assert( _.strIs( chunkFrame.result ) );
  _.assert( _.arrayIs( chunkFrame.usedIncludeFrames ) );
  _.assert( chunkFrame.usedFileFrames.length === 0 );
  _.assert( arguments.length === 1 );

  // debugger;
  // if( chunkFrame.fileFrame.file.relative.indexOf( 'index.hht' ) !== -1 )
  // debugger;
  // if( chunkFrame.usedIncludeFrames.length )
  // debugger;

  /* */

  for( var i = 0 ; i < chunkFrame.usedIncludeFrames.length ; i += 1 )
  {
    var usedIncludeFrame = chunkFrame.usedIncludeFrames[ i ];
    _.assert( usedIncludeFrame.fileFrames.length === usedIncludeFrame.files.length );
    _.arrayAppendArray( chunkFrame.usedFileFrames,usedIncludeFrame.fileFrames );
  }

  /* */

  var _index = 0;
  for( var i = 0 ; i < chunkFrame.usedIncludeFrames.length ; i += 1 )
  {
    var usedIncludeFrame = chunkFrame.usedIncludeFrames[ i ];

    _.assert( usedIncludeFrame.fileFrames.length === usedIncludeFrame.files.length );

    for( var f = 0 ; f < usedIncludeFrame.fileFrames.length ; f += 1 ) ( function()
    {
      var fileFrame = usedIncludeFrame.fileFrames[ f ];

      con.choke();
      _index += 1;
      var index = _index;

      if( err && !fileFrame.consequence )
      return;

      _.assert( fileFrame,'unexpected' );

      if( fileFrame.error )
      {
        debugger;
        if( !err )
        err = _.err( fileFrame.error );
        else
        _.errAttend( fileFrame.error );
      }
      else
      {
        _.assert( _.strIs( fileFrame.result ),'expects string, but got',_.strTypeOf( fileFrame.result ) );
        var formatted = self.linkFormat
        ({
          userChunkFrame : chunkFrame,
          usedFileFrame : fileFrame,
          usedIncludeFrame : usedIncludeFrame,
        });

        formatted = wConsequence.from( formatted );
        formatted.ifNoErrorThen( function( formatted )
        {
          _.assert( _.strIs( formatted ) );
          result[ index ] = formatted;
        });
        formatted.doThen( con );
      }

    })();

  }

  if( err )
  throw _.errLogOnce( err );

  /* */

  // if( chunkFrame.usedIncludeFrames.length )
  // debugger;

  con
  .give()
  .ifNoErrorThen( function()
  {
    // if( chunkFrame.usedIncludeFrames.length )
    // debugger;

    if( result.length )
    chunkFrame.result = result.join( '' ) + chunkFrame.result;
    return chunkFrame.result;
  })
  .ifNoErrorThen( function( arg )
  {
    if( self.verbosity > 1 )
    logger.log( '_chunkFormat',chunkFrame.fileFrame.file.absolute,chunkFrame.chunk.index );
    return self._chunkFormat( chunkFrame,arg );
  })
  .ifNoErrorThen( function( arg )
  {
    // debugger;
    _.assert( _.strIs( arg ) );
    return arg;
  })
  ;

  /* */

  // if( chunkFrame.usedIncludeFrames.length )
  // debugger;
  return con;
}

//

function _chunkFormat( chunkFrame,text )
{
  var self = this;

  _.assert( arguments.length === 2 );

  return self.formattersApply
  ({
    formatters : self.chunkFormatters,
    frame : chunkFrame,
    categories : chunkFrame.fileFrame.categories,
  });

}

// --
// etc
// --

function categoriesForFile( fileFrame )
{
  var self = this;
  var result = [];
  var file = fileFrame.file;

  _.assert( arguments.length === 1 );
  _.assert( _.construction.isLike( fileFrame,FileFrame ) );
  _.assert( file instanceof _.FileRecord );

  /* arbitrary categories */

  for( var c in self.arbitraryCategorizers )
  {
    var categorizer = self.arbitraryCategorizers[ c ];
    _.assert( _.routineIs( categorizer ) );
    try
    {
      var category = categorizer.call( self,file );
    }
    catch( err )
    {
      var msg = 'Categorizer ' + c + ' failed\n';
      throw _.err( msg,err )
    }
    if( category )
    {
      _.assert( _.atomicIs( category ) );
      if( !_.strIs( category ) )
      category = c;
      result.push( category );
    }
  }

  // if( fileFrame.file.absolute.indexOf( 'simplify-js' ) !== -1 )
  // debugger;

  /* file categories */

  for( var c in self.fileCategorizers )
  {
    var categorizer = self.fileCategorizers[ c ];
    _.assert( _.routineIs( categorizer ) );
    var category = categorizer.call( self,file );
    if( category )
    {
      _.assert( _.atomicIs( category ) );
      if( !_.strIs( category ) )
      category = c;
      result.push( category );
    }
  }

  return result;
}

//

function _categoriesForLink( o )
{
  var self = this;
  var result = [];

  _.assert( arguments.length === 1 );

  /* file categories */

  for( var c = 0 ; c < o.user.fileFrame.categories.length ; c++ )
  {
    _.arrayAppendOnce( result , 'in.' + o.user.fileFrame.categories[ c ] );
  }

  for( var c = 0 ; c < o.used.fileFrame.categories.length ; c++ )
  {
    _.arrayAppendOnce( result , o.used.fileFrame.categories[ c ] );
  }

  /* link categories */

  for( var c in self.linkCategorizers )
  {
    var categorizer = self.linkCategorizers[ c ];
    _.assert( _.routineIs( categorizer ) );
    var category = categorizer.call( self,o );
    if( category )
    {
      _.assert( _.atomicIs( category ) );
      if( !_.strIs( category ) )
      category = c;
      _.arrayAppendOnce( result,category );
    }
  }

  if( self.linkAttributeDefault !== '' )
  if( result.length === 0 )
  result.push( self.linkAttributeDefault );

  return result;
}

//

function _categoriesCheck( categories,filter )
{
  var self = this;

  _.assert( arguments.length === 2 );

  if( filter.ifAny )
  if( !_.arrayHasAny( categories,filter.ifAny ) )
  return false;

  if( filter.ifAll )
  if( !_.arrayHasAll( categories,filter.ifAll ) )
  return false;

  if( filter.ifNone )
  if( !_.arrayHasNone( categories,filter.ifNone ) )
  return false;

  return true;
}

//

function formattersApply( o )
{
  var self = this;
  var con = new _.Consequence().give( o.frame.result );

  _.assert( arguments.length === 1 );

  if( !o.categories.length )
  return con;

  o.executor = self;

  // if( !_.construction.isLike( o.frame,ChunkFrame ) )
  // debugger;
  // if( !_.construction.isLike( o.frame,ChunkFrame ) )
  // _.diagnosticWatchFields
  // ({
  //   dst : o.frame,
  //   names : 'result',
  // });

  // if( o.frame.user && o.frame.user.file.relative.indexOf( '.html' ) !== -1 )
  // debugger;

  for( var f = 0 ; f < o.formatters.length ; f++ ) ( function()
  {

    var ff = f;
    con.ifNoErrorThen( function( arg )
    {
      o.formatter = o.formatters[ ff ];
      return self.formatterTry( o );
    });

  })();

  // if( !_.construction.isLike( o.frame,ChunkFrame ) )
  // debugger;

  // con.got( function( err,arg )
  // {
  //
  //   if( o.frame.user && o.frame.user.file.relative.indexOf( '.html' ) !== -1 )
  //   debugger;
  //
  //   // if( !_.construction.isLike( o.frame,ChunkFrame ) )
  //   // debugger;
  //
  //   this.give( err,arg );
  // });

  con.ifNoErrorThen( function( arg )
  {

    // if( !_.construction.isLike( o.frame,ChunkFrame ) )
    // debugger;

    // if( o.frame.user && o.frame.user.file.relative.indexOf( '.html' ) !== -1 )
    // debugger;

    return o.frame.result;
  });

  return con;
}

//

function formatterTry( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( o.formatter );

  // if( o.frame.fileFrame && o.frame.fileFrame.file.absolute.indexOf( 'index.hht' ) !== -1 )
  // debugger;

  if( !self._categoriesCheck( o.categories,o.formatter ) )
  return;

  return self.formatterApply( o );
}

//

function formatterApply( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( o.formatter );

  if( !o.usedFileFrames )
  {

    var usedFileFrames = o.frame.usedFileFrames;
    if( o.formatter.onlyForUsedFiles )
    {

      usedFileFrames = [];
      for( var u = 0 ; u < o.frame.usedFileFrames.length ; u++ )
      {
        var usedFileFrame = o.frame.usedFileFrames[ u ];
        if( self._categoriesCheck( usedFileFrame.categories,o.formatter.onlyForUsedFiles ) )
        usedFileFrames.push( usedFileFrame );
      }

      if( !usedFileFrames.length )
      return;

    }
    o.usedFileFrames = usedFileFrames;

  }

  _.assert( _.routineIs( o.formatter.format ),'formatter should have routine (-format-)' );
  var r = o.formatter.format.call( self,o );

  _.assert( r === undefined || _.consequenceIs( r ) );

  if( _.consequenceIs( r ) )
  r.ifNoErrorThen( function( arg )
  {
    o.usedFileFrames = null;
  })
  else
  {
    o.usedFileFrames = null;
  }

  return r;
}

//

function linkFor( userChunkFrame,usedFileFrame )
{
  var self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.construction.isLike( userChunkFrame,ChunkFrame ) );
  _.assert( _.construction.isLike( usedFileFrame,FileFrame ) || usedFileFrame instanceof _.FileRecord );

  var usedFile;
  if( usedFileFrame instanceof _.FileRecord )
  {
    usedFile = usedFileFrame;
    usedFileFrame = null;
  }
  else
  {
    usedFile = usedFileFrame.file;
  }

  var link = Object.create( null );
  link.result = usedFileFrame ? usedFileFrame.result : null;

  link.used = Object.create( null );
  link.used.fileFrame = usedFileFrame;
  link.used.includeFrame = usedFileFrame ? usedFileFrame.includeFrame : null;
  link.used.file = usedFile;
  link.used.ext = usedFile.ext.toLowerCase();

  link.user = Object.create( null );
  link.user.chunkFrame = userChunkFrame;
  link.user.fileFrame = userChunkFrame.fileFrame;
  link.user.includeFrame = userChunkFrame.fileFrame.includeFrame;
  link.user.file = userChunkFrame.fileFrame.file;
  link.user.ext = link.user.file.ext.toLowerCase();

  link.categories = self._categoriesForLink( link );

  Object.preventExtensions( link );

  return link;
}

//

function linkFormat( o )
{
  var self = this;

  if( !o.link )
  o.link = self.linkFor( o.userChunkFrame,o.usedFileFrame );

  if( !o.usedIncludeFrame )
  o.usedIncludeFrame = o.link.used.includeFrame;

  _.assert( o.usedIncludeFrame );
  _.assert( arguments.length === 1 );
  _.assert( _.construction.isLike( o.usedIncludeFrame,IncludeFrame ) );

  if( self.verbosity > 2 )
  logger.log
  (
    'linkFormat',
    o.link.user.file.relative,
    '#',
    o.link.user.chunkFrame.chunk.index,
    ':',
    o.link.used.file.relative
  );

  // if( o.link.user.file.relative.indexOf( '.html' ) !== -1 )
  // debugger;

  var formatted = self.formattersApply
  ({
    formatters : self.linkFormatters,
    frame : o.link,
    categories : o.link.categories
  });

  var got = formatted;

  // formatted.got( function( err,arg )
  // {
  //   this.give( err,arg );
  // });

  // var got = wConsequence.from( o.link.result );

  got.got( function( err,arg )
  {
    _.assert( _.strIs( arg ),'expects string' );
    o.link.result = arg;
    // if( o.link.user.file.relative.indexOf( '.html' ) !== -1 )
    // debugger;
    this.give( err,arg );
  });

  // if( _.consequenceIs( formatted ) )
  // got.andThen( formatted );

  if( o.usedIncludeFrame.includeOptions.onIncludeFromat )
  {
    got.ifNoErrorThen( function( arg )
    {
      o.link.result = arg;
      var r = o.usedIncludeFrame.includeOptions.onIncludeFromat.call( self,o.link );
      if( _.strIs( r ) )
      o.link.result = r;
      _.assert( r === undefined || _.strIs( r ),'expects string or nothing from (-onIncludeFromat-)' );
      _.assert( _.strIs( o.link.result ) );
      return o.link.result;
    });
  }

  return got;
}

linkFormat.defaults =
{
  link : null,
  userChunkFrame : null,
  usedFileFrame : null,
  usedIncludeFrame : null,
}

//

function linkFormatExplicit( o )
{
  var self = this;

  if( !o.filePath )
  o.filePath = _.pathJoin( o.formatter.frame.fileFrame.file.dir,o.formatter.frame.fileFrame.file.name + '.manual.js' );
  var joinedFile = o.formatter.frame.fileFrame.file.clone( o.filePath );

  var fileFrame = self.fileFrameFor
  ({
    file : joinedFile,
    includeFrame : o.formatter.frame.fileFrame.includeFrame,
  });

  var link = self.linkFor( o.formatter.frame , fileFrame );
  if( o.removeCategories )
  _.arrayRemoveArrayOnce( link.categories,o.removeCategories );
  if( o.addCategories )
  _.arrayAppendArrayOnce( link.categories,o.addCategories );

  var formatted = self.linkFormat
  ({
    link : link,
  });

  formatted.ifNoErrorThen( function _formatReplaceByFileAfter( arg )
  {
    // debugger;
    _.assert( _.strIs( arg ) );
    o.formatter.frame.result += arg;
    return arg;
  });

  // debugger;
  return formatted;
}

linkFormatExplicit.default =
{
  filePath : null,
  formatter : null,
  removeCategories : null,
  addCategories : null,
}

//

function _fileCategorizersSet( categorizers )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( categorizers ),'expects object (-categorizers-)' );

  self[ fileCategorizersSymbol ] = categorizers;

  self._fileCategorizersChanged();

  return categorizers;
}

//

function _fileCategorizersChanged()
{
  var self = this;
  var categorizers = self[ fileCategorizersSymbol ];

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( categorizers ),'expects object (-categorizers-)' );

  for( var c in categorizers )
  {
    var categorizer = categorizers[ c ];

    if( _.strIs( categorizer ) )
    categorizer = [ categorizer ];
    if( _.arrayIs( categorizer ) ) ( function()
    {
      var exts = categorizer;
      categorizer = function categorizer( file )
      {
        return _.arrayHasAny( exts,file.exts );
      }
    })();

    categorizers[ c ] = categorizer;
  }

}

// --
// used
// --

function filesUsedGet( includes,result )
{
  var self = this;
  var result = result || [];

  _.assert( _.arrayIs( includes ) );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  for( var i = 0 ; i < includes.length ; i++ )
  {
    var includeFrame = includes[ i ];
    _.assert( _.construction.isLike( includeFrame,IncludeFrame ) );
    _.arrayAppendArray( result,includeFrame.files );
    self.filesUsedGet( includeFrame.usedIncludeFrames,result );
  }

  return result;
}

//

function includesUsedInherit( includeFrame,fileFrame )
{
  var self = this;

  _.assert( arguments.length === 2 );

  _.arrayAppendArray( includeFrame.usedIncludeFrames , fileFrame.usedIncludeFrames );

}

// --
// construction
// --

var IncludeFrame = _.like()
.also
({

  resolveOptions : null,
  files : null,

  includeOptions : null,
  consequence : null,
  pathTranslator : null,

  userChunkFrame : null,
  userIncludeFrame : null,
  fileFrames : [],
  usedIncludeFrames : [],

  externals : null,
  context : null,
  session : null,

})
.end

includeFrameBegin.defaults = IncludeFrame;
includeFrameEnd.defaults = IncludeFrame;

//

var FileFrame = _.like()
.also
({
  includeFrame : null,
  includeFrames : [],

  file : null,
  pathTranslator : null,

  usedIncludeFrames : [],
  usedFiles : null,

  chunks : null,

  context : null,
  externals : null,

  category : null,

  executing : 0,
  executed : 0,
  result : null,
  error : null,
  consequence : null,

  code : null,
  categories : [],

})
.end

fileFrameFor.defaults = FileFrame;

//

var ChunkFrame = _.like()
.also
({
  chunk : null,
  fileFrame : null,
  externals : null,
  usedIncludeFrames : [],
  usedFileFrames : [],
  syncExternal : null,
  syncInternal : null,
  execution : null,
  result : null,
  resultRaw : null,
})
.end

chunkFrameFor.defaults = ChunkFrame;
chunkExecute.defaults = ChunkFrame;

// --
// relationships
// --

var fileCategorizersSymbol = Symbol.for( 'fileCategorizers' );

var Composes =
{

  pathTranslator : new wPathTranslator({ realCurrentDirPath : _.pathRefine( __dirname ) }),

  // currentDirPath : _.pathRefine( __dirname ),
  // virtualRootPath : '/',
  // realRootPath : '/',
  // realRelativePath : '/',

  warnBigFiles : 1 << 19,
  debug : 0,
  verbosity : 1,

  linkAttributeDefault : '',

}

var Aggregates =
{

  arbitraryCategorizers : Object.create( null ),
  linkCategorizers : Object.create( null ),
  fileCategorizers : Object.create( null ),

  linkFormatters : [],
  chunkFormatters : [],

}

var Associates =
{
  fileProvider : null,
  archive : null,
  context : Object.create( null ),
}

var Restricts =
{
  session : null,
  includeFrames : [],
}

var Statics =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,

  languageFromFilePath : languageFromFilePath,
  scriptExecute : scriptExecute,

  ecmaExecute : ecmaExecute,

  coffeeCompile : coffeeCompile,
  coffeeExecute : coffeeExecute,


  /* include */

  sessionMake : sessionMake,

  includeFrameBegin : includeFrameBegin,
  includeFrameEnd : includeFrameEnd,

  _includeAct : _includeAct,
  _includeFromChunk : _includeFromChunk,
  include : include,


  /* file */

  filesExecute : filesExecute,

  fileExecute : fileExecute,
  _fileExecute : _fileExecute,

  filesFilter : filesFilter,
  fileFrameFor : fileFrameFor,


  /* chunk */

  chunkFrameFor : chunkFrameFor,
  chunkExecute : chunkExecute,
  _chunkExecute : _chunkExecute,
  _chunkExpose : _chunkExpose,
  _chunkTabulate : _chunkTabulate,
  _chunksSplit : _chunksSplit,
  _chunkConcat : _chunkConcat,
  _chunkFormat : _chunkFormat,


  /* etc */

  categoriesForFile : categoriesForFile,
  _categoriesForLink : _categoriesForLink,
  _categoriesCheck : _categoriesCheck,

  formattersApply : formattersApply,
  formatterTry : formatterTry,
  formatterApply : formatterApply,

  linkFor : linkFor,
  linkFormat : linkFormat,
  linkFormatExplicit : linkFormatExplicit,

  _fileCategorizersSet : _fileCategorizersSet,
  _fileCategorizersChanged : _fileCategorizersChanged,


  /* used */

  filesUsedGet : filesUsedGet,
  includesUsedInherit : includesUsedInherit,


  /* relationships */

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

_.accessor
({
  object : Self.prototype,
  names :
  {
    fileCategorizers : 'fileCategorizers',
  },
})

//

// _.accessorReadOnly
// ({
//   object : Self.prototype,
//   names :
//   {
//     context : 'context',
//   },
// })

//

_.accessorForbid
({
  object : Self.prototype,
  names :
  {
    conChunkBegin : 'conChunkBegin',
    conChunkEnd : 'conChunkEnd',
    prefix : 'prefix',
    postfix : 'postfix',
    currentDirPath : 'currentDirPath',
    virtualRootPath : 'virtualRootPath',
    realRootPath : 'realRootPath',
    realRelativePath : 'realRelativePath',
  },
});

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
_global_[ Self.name ] = _[ Self.nameShort ] = Self;

})();
