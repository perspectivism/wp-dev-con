<?php
/**
 * Plugin Name: Pro WP Dev Containers Plugin
 * Plugin URI: https://github.com/perspectivism
 * Description: A simple WordPress plugin.
 * Author: Pero Matić
 * Author URI: https://github.com/perspectivism
 * Version: 1.0
 * License: Apache License, Version 2.0
 * License URI: http://www.apache.org/licenses/LICENSE-2.0
 * Text Domain: pro-wp-dev-con-theme
 */

// Load our custom TypeScript built by parcel
add_action('wp_enqueue_scripts', function () {
    wp_enqueue_script(
        'custom-plugin-js',
        plugin_dir_url(__FILE__) . 'dist/greet.js'
    );
});
