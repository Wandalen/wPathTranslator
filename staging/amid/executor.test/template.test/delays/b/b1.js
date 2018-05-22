(function() {

console.log( 'b1:before' );

//
//>-->//
return _.timeOut( 1000,() => `// b1` );
//<--<//
//

console.log( 'b1:after' );

});
