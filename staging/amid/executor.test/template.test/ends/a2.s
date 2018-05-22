(function() {

console.log( 'a2:before' );

//
//>-->//

include({ ends : [ '.s', '.js' ], path : 'b/**' });

return `// a2`;
//<--<//
//

console.log( 'a2:after' );

});
