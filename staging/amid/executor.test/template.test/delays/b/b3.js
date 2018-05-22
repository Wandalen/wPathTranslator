(function() {

console.log( 'b3:before' );

//
//>-->//
return _.timeOut( 1000,() => `// b3` );
//<--<//
//

console.log( 'b3:after' );

});
