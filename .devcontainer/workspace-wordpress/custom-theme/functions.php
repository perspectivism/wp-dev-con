<?php // Load our custom CSS and JavaScript built by parcel
add_action('wp_enqueue_scripts', function () {
    wp_enqueue_style(
        'custom-theme-css',
        get_stylesheet_directory_uri() . '/dist/index.css'
    );

    wp_enqueue_script(
        'custom-theme-js',
        get_stylesheet_directory_uri() . '/dist/index.js'
    );
});
