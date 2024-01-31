<!DOCTYPE html>
<html>

<head>
    <meta charset="<?php bloginfo('charset'); ?>">
    <title><?php wp_title('|', true, 'right'); ?></title>
    <?php wp_head(); ?>
</head>

<body class="mx-auto w-2/3 mt-6">    
    <h1 class="text-6xl font-bold my-3"><?php bloginfo('name'); ?></h1>
    <h2 class="text-3xl italic mb-8"><?php bloginfo('description'); ?></h2>

    <?php
    if (have_posts()):
        while (have_posts()):
            the_post();
            the_title('<h3 class="font-semibold">', '</h3>');
            the_content();
        endwhile;
    endif;

    wp_footer();
    ?>
</body>

</html>