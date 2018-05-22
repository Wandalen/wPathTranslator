(function() {

console.log( 'a1:before' );

//
//>-->//

include({ ends : '.s', path : 'b/**' });

return `// a1`;
//<--<//
//

console.log( 'a1:after' );

});
