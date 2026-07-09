CREATE TABLE IF NOT EXISTS `spotify_saved_songs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(60) NOT NULL,
    `youtube_url` text NOT NULL,
    `title` varchar(255) NOT NULL,
    `thumbnail` text NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
