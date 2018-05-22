(function() {

console.log( 'a:before' );

//
//>-->//

include
({
  ifAny : 'script.server',
  path : 'c/**',
});

return `// a`
//<--<//
//

console.log( 'a:after' );

});
