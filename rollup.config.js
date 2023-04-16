import resolve from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
// import pkg from './package.json' assert {type: 'json'};

export default [
	// browser-friendly UMD build
	{
		input: ['.local/rollup/out-tsc', 'src/erc2535proxy.js'],
		output: {
			dir: 'dist'
		},
		plugins: [
			resolve(), // so Rollup can find `ms`
			commonjs() // so Rollup can convert `ms` to an ES module
		]
	}
];