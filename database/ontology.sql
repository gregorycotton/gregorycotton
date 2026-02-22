-- -- PRAGMA foreign_keys = OFF;

-- -- Section 1: Drop existing tables (if they exist)
-- DROP TABLE IF EXISTS projects;
-- DROP TABLE IF EXISTS modalities;
-- DROP TABLE IF EXISTS mediums;
-- DROP TABLE IF EXISTS tools;
-- DROP TABLE IF EXISTS objects;
-- DROP TABLE IF EXISTS collaborators;
-- DROP TABLE IF EXISTS keywords;
-- DROP TABLE IF EXISTS albums;
-- DROP TABLE IF EXISTS fieldnotes;

-- -- Section 2: Create tables
-- -- IMPORTANT: Schema for tables other than albums/fieldnotes is INFERRED. Adjust if needed.

-- CREATE TABLE projects (
--     UUID TEXT PRIMARY KEY,
--     Title TEXT,
--     ShortDescription TEXT,
--     Year INTEGER,
--     FeaturedWork TEXT -- Assuming TEXT for 'TRUE'/'FALSE'
-- );

-- CREATE TABLE modalities (
--     UUID TEXT, -- Assumed Foreign Key to projects
--     Modality TEXT
--     -- Consider adding FOREIGN KEY (UUID) REFERENCES projects(UUID) if needed
-- );

-- CREATE TABLE mediums (
--     UUID TEXT, -- Assumed Foreign Key to projects
--     Medium TEXT
--     -- Consider adding FOREIGN KEY (UUID) REFERENCES projects(UUID) if needed
-- );

-- CREATE TABLE tools (
--     UUID TEXT, -- Assumed Foreign Key to projects
--     Tool TEXT
--     -- Consider adding FOREIGN KEY (UUID) REFERENCES projects(UUID) if needed
-- );

-- CREATE TABLE objects (
--     UUID TEXT, -- Assumed Foreign Key to projects
--     Object TEXT
--     -- Consider adding FOREIGN KEY (UUID) REFERENCES projects(UUID) if needed
-- );

-- CREATE TABLE collaborators (
--     UUID TEXT, -- Assumed Foreign Key to projects
--     Collaborator TEXT
--     -- Consider adding FOREIGN KEY (UUID) REFERENCES projects(UUID) if needed
-- );

-- CREATE TABLE keywords (
--     UUID TEXT, -- Assumed Foreign Key to projects
--     Keyword TEXT
--     -- Consider adding FOREIGN KEY (UUID) REFERENCES projects(UUID) if needed
-- );

-- -- Create the albums table (Using your provided schema)
-- CREATE TABLE albums (
--     UUID TEXT PRIMARY KEY,
--     FileName TEXT,
--     ShortDescription TEXT,
--     Camera TEXT,
--     SizeBytes INTEGER,
--     Year INTEGER
-- );

-- -- Create the fieldnotes table (Using your provided schema)
-- CREATE TABLE fieldnotes (
--     UUID TEXT PRIMARY KEY,
--     Title TEXT,
--     ShortDescription TEXT,
--     PublishedDate TEXT, -- Stored as 'YYYY-MM-DD'
--     LastUpdated TEXT     -- Stored as 'YYYY-MM-DD'
-- );


-- -- Section 3: Repopulate tables with provided data

-- -- Populate projects table
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES
-- ('P001', 'Une bouteille de peinture', 'My magnum opus', 2007, 'FALSE'),
-- ('P002', 'Assorted surrealist photography', '2016-2018 surrealist images', 2018, 'FALSE'),
-- ('P003', 'PACE Magazine cover', 'Cover image for a local arts magazine', 2018, 'FALSE'),
-- ('P004', 'Misc. Etc. Hong Kong', 'Reflection on a dense city', 2019, 'TRUE'),
-- ('P005', 'The Urban Farmer', 'A man forced to farm in his apartment', 2019, 'FALSE'),
-- ('P006', 'The Open House', 'Party, live music, art exhibits', 2020, 'FALSE'),
-- ('P007', 'MyOAP Dashboard', 'Web portal for a public service', 2020, 'FALSE'),
-- ('P008', 'Public Secure SSO', 'Single sign-on for the provincial government', 2020, 'FALSE'),
-- ('P009', 'Order', 'Digital art series', 2020, 'FALSE'),
-- ('P010', 'The Food Library', 'Exhibit about sustainability and food security', 2021, 'FALSE'),
-- ('P011', 'Patchwork', 'Generatively reassembling neighbourhoods', 2021, 'FALSE'),
-- ('P012', 'Bay Area Climate Change Council', 'Design work for a non-profit', 2022, 'FALSE'),
-- ('P013', 'Pen Portraits', 'Creating personas', 2022, 'FALSE'),
-- ('P014', 'To Stay At Home', 'Branding and artwork for a musician', 2022, 'FALSE'),
-- ('P015', 'Park Library', 'Online-outdoor library for hosting digital art', 2023, 'TRUE'),
-- ('P016', 'Live Text Poetry', 'Abstract poetry made using Apple Live Text', 2023, 'TRUE'),
-- ('P017', 'Pemichangan Landscape Study', 'Landscapes taken from a car window', 2023, 'FALSE'),
-- ('P018', 'I’ll make it easy to understand me', 'Ambient EP with an accompanying music video', 2023, 'FALSE'),
-- ('P019', 'The beginning/end of something.', 'Video reflecting on my years between university and moving to Lisbon', 2023, 'FALSE'),
-- ('P020', 'Greg''s Fridge', 'My website guestbook', 2023, 'FALSE'),
-- ('P021', 'Online Together', 'Wordless communication platform', 2023, 'FALSE'),
-- ('P022', 'Forest Simulator', 'Forest scenes for meditation', 2023, 'FALSE'),
-- ('P023', 'Browser Expressionism', 'Tool for abstract browser art', 2024, 'TRUE'),
-- ('P024', 'Spotify multi-disc player', 'Multi-disc shuffle functionality for Spotify', 2024, 'TRUE'),
-- ('P025', 'Sunset Study', 'Abstracted sunset photos in Sintra', 2024, 'FALSE'),
-- ('P026', 'Anvil', 'Website for a video production duo', 2024, 'TRUE'),
-- ('P027', 'Greg’s Window Washing Service', 'Experiment with browser pop-ups', 2024, 'FALSE'),
-- ('P028', 'DSCN9372 ++ (Budapest time-lapse)', 'Handheld timelapse', 2024, 'FALSE'),
-- ('P029', 'Piano export . 2024 09 25-29', 'Five days of generative piano exports', 2024, 'FALSE'),
-- ('P030', 'iMessage UI Collages', 'Collages created using native iOS functionality', 2024, 'TRUE'),
-- ('P031', 'Untitled (Map Assortment)', 'Satellite imagery selections', 2024, 'FALSE'),
-- ('P032', 'Assorted Collaborative Paintings', 'Made over the course of a week in Prague', 2024, 'FALSE'),
-- ('P033', 'Toby’s Barbershop', 'Abstracted vlog centered around a parking lot haircut', 2024, 'FALSE'),
-- ('P034', 'DSCN7847 – DSCN8596', 'Christmas and New Year’s in Europe', 2024, 'FALSE');

-- -- Populate modalities table
-- INSERT INTO modalities (UUID, Modality) VALUES
-- ('P001', 'Traditional'),
-- ('P002', 'Digital'),
-- ('P003', 'Digital'),
-- ('P004', 'Digital'),
-- ('P005', 'Digital'),
-- ('P006', 'Experiential'),
-- ('P007', 'Digital'),
-- ('P008', 'Digital'),
-- ('P009', 'Digital'),
-- ('P010', 'Digital'),
-- ('P011', 'Digital'),
-- ('P012', 'Digital'),
-- ('P013', 'Traditional'),
-- ('P014', 'Digital'),
-- ('P015', 'Digital'),
-- ('P016', 'Digital'),
-- ('P017', 'Digital'),
-- ('P018', 'Digital'),
-- ('P019', 'Digital'),
-- ('P020', 'Digital'),
-- ('P021', 'Digital'),
-- ('P022', 'Digital'),
-- ('P023', 'Digital'),
-- ('P024', 'Digital'),
-- ('P025', 'Digital'),
-- ('P026', 'Digital'),
-- ('P027', 'Digital'),
-- ('P028', 'Digital'),
-- ('P029', 'Digital'),
-- ('P030', 'Digital'),
-- ('P031', 'Digital'),
-- ('P032', 'Traditional'),
-- ('P033', 'Digital'),
-- ('P034', 'Digital');

-- -- Populate mediums table
-- INSERT INTO mediums (UUID, Medium) VALUES
-- ('P001', 'Painting'),
-- ('P002', 'Photography'),
-- ('P003', 'Photography'),
-- ('P004', 'Photography'),
-- ('P005', 'Photography'),
-- ('P006', 'Gallery'),
-- ('P007', 'UX design'), ('P007', 'Product design'),
-- ('P008', 'UX design'), ('P008', 'Product design'),
-- ('P009', 'Graphic design'), ('P009', 'Drawing'),
-- ('P010', 'UX design'), ('P010', 'Video'), ('P010', '3D modelling'), ('P010', 'Writing'), ('P010', 'Speculative design'), ('P010', 'Design fiction'),
-- ('P011', 'Photography'), ('P011', 'Generative art'),
-- ('P012', 'Graphic design'),
-- ('P013', 'Drawing'),
-- ('P014', 'Graphic design'), ('P014', 'Video'),
-- ('P015', 'Web art'),
-- ('P016', 'Generative art'), ('P016', 'Writing'),
-- ('P017', 'Photography'),
-- ('P018', 'Music'), ('P018', 'Video'),
-- ('P019', 'Video'), ('P019', 'Collage'),
-- ('P020', 'Web art'),
-- ('P021', 'Web art'),
-- ('P022', 'Web art'), ('P022', 'Writing'),
-- ('P023', 'Web art'),
-- ('P024', 'Web app'),
-- ('P025', 'Photography'),
-- ('P026', 'Web art'), ('P026', 'Graphic design'),
-- ('P027', 'Web art'),
-- ('P028', 'Video'), ('P028', 'Photography'),
-- ('P029', 'Music'), ('P029', 'Generative art'),
-- ('P030', 'Collage'),
-- ('P031', 'Collage'),
-- ('P032', 'Collage'), ('P032', 'Drawing'), ('P032', 'Painting'), ('P032', 'Calligraphy'),
-- ('P033', 'Video'),
-- ('P034', 'Video');

-- -- Populate tools table
-- INSERT INTO tools (UUID, Tool) VALUES
-- ('P001', 'Watercolour paint'),
-- ('P002', 'Photoshop'), ('P002', 'Digital camera'),
-- ('P003', 'Photoshop'), ('P003', 'Digital camera'),
-- ('P004', 'Photoshop'), ('P004', 'Digital camera'),
-- ('P005', 'Photoshop'), ('P005', 'Digital camera'),
-- ('P006', 'N/A'),
-- ('P007', 'Photoshop'), ('P007', 'Figma'), ('P007', 'Miro'),
-- ('P008', 'Photoshop'), ('P008', 'Figma'), ('P008', 'Miro'),
-- ('P009', 'Photoshop'), ('P009', 'Pen & paper'),
-- ('P010', 'Figma'), ('P010', 'Blender'), ('P010', 'Premiere Pro'), ('P010', 'Photoshop'),
-- ('P011', 'Photoshop'), ('P011', 'Digital camera'), ('P011', 'Java'),
-- ('P012', 'Figma'), ('P012', 'Illustrator'),
-- ('P013', 'Pen & Paper'), ('P013', 'Sticky notes'),
-- ('P014', 'Premiere Pro'), ('P014', 'Photoshop'), ('P014', 'Digital camera'),
-- ('P015', 'HTML'), ('P015', 'CSS'), ('P015', 'JavaScript'),
-- ('P016', 'iOS'), ('P016', 'Photoshop'), ('P016', 'Pen & paper'),
-- ('P017', 'Photoshop'), ('P017', 'Digital camera'),
-- ('P018', 'GarageBand'), ('P018', 'Ableton Live'), ('P018', 'Premiere Pro'), ('P018', 'Photoshop'), ('P018', 'Google Earth'),
-- ('P019', 'Photoshop'), ('P019', 'Premiere Pro'), ('P019', 'Digital Camera'),
-- ('P020', 'HTML'), ('P020', 'CSS'), ('P020', 'JavaScript'),
-- ('P021', 'HTML'), ('P021', 'CSS'), ('P021', 'JavaScript'),
-- ('P022', 'HTML'), ('P022', 'CSS'), ('P022', 'JavaScript'),
-- ('P023', 'HTML'), ('P023', 'CSS'), ('P023', 'JavaScript'),
-- ('P024', 'HTML'), ('P024', 'CSS'), ('P024', 'JavaScript'), ('P024', 'Node.js'),
-- ('P025', 'Photoshop'), ('P025', 'Digital camera'),
-- ('P026', 'HTML'), ('P026', 'CSS'), ('P026', 'JavaScript'), ('P026', 'Photoshop'), ('P026', 'Figma'),
-- ('P027', 'HTML'), ('P027', 'CSS'), ('P027', 'JavaScript'),
-- ('P028', 'Premiere Pro'), ('P028', 'Digital camera'),
-- ('P029', 'Ableton Live'),
-- ('P030', 'iOS'),
-- ('P031', 'Google Earth'), ('P031', 'Photoshop'),
-- ('P032', 'Pen & paper'), ('P032', 'Watercolour paint'),
-- ('P033', 'Premiere Pro'), ('P033', 'Digital camera'),
-- ('P034', 'Premiere Pro'), ('P034', 'Digital camera');

-- -- Populate objects table
-- INSERT INTO objects (UUID, Object) VALUES
-- ('P001', 'Painting(s)'),
-- ('P002', 'Image(s)'),
-- ('P003', 'Magazine cover'),
-- ('P004', 'Image(s)'),
-- ('P005', 'Image(s)'),
-- ('P006', 'Exhibit'),
-- ('P007', 'Wireframes'), ('P007', 'Case study'),
-- ('P008', 'Wireframes'), ('P008', 'Case study'),
-- ('P009', 'Image(s)'),
-- ('P010', 'Exhibit'),
-- ('P011', 'Image(s)'),
-- ('P012', 'Design assets'),
-- ('P013', 'Drawing(s)'),
-- ('P014', 'Album art'), ('P014', 'Spotify canvas'),
-- ('P015', 'Website'),
-- ('P016', 'Image(s)'),
-- ('P017', 'Image(s)'),
-- ('P018', 'Extended play'), ('P018', 'Music video'),
-- ('P019', 'Vlog'),
-- ('P020', 'Website'),
-- ('P021', 'Website'),
-- ('P022', 'Website'),
-- ('P023', 'Website'),
-- ('P024', 'Website'),
-- ('P025', 'Image(s)'),
-- ('P026', 'Website'),
-- ('P027', 'Website'),
-- ('P028', 'Timelapse'),
-- ('P029', 'Extended play'),
-- ('P030', 'Image(s)'),
-- ('P031', 'Image(s)'),
-- ('P032', 'Painting(s)'),
-- ('P033', 'Vlog'),
-- ('P034', 'Vlog');

-- -- Populate collaborators table
-- INSERT INTO collaborators (UUID, Collaborator) VALUES
-- ('P004', 'Toby Sherman'), ('P004', 'Tank Buzadi'),
-- ('P014', 'Adam Collings'),
-- ('P016', 'Toby Sherman'),
-- ('P026', 'Toby Sherman'), ('P026', 'Tank Buzadi'),
-- ('P030', 'Toby Sherman'),
-- ('P032', 'Toby Sherman'), ('P032', 'Emmanuelle Slavutych Gangé'), ('P032', 'Mihail Miceski'), ('P032', 'Sabina Jiaxin Han'),
-- ('P033', 'Toby Sherman'),
-- ('P034', 'Toby Sherman');

-- -- Populate keywords table
-- INSERT INTO keywords (UUID, Keyword) VALUES
-- ('P001', 'Self'), ('P001', 'Abstraction'),
-- ('P002', 'Self'), ('P002', 'Sustainability'), ('P002', 'Geography'), ('P002', 'Culture'), ('P002', 'Technology'),
-- ('P003', 'Commercial / Client'), ('P003', 'Culture'),
-- ('P004', 'Culture'), ('P004', 'Geography'), ('P004', 'Sustainability'),
-- ('P005', 'Geography'), ('P005', 'Self'), ('P005', 'Abstraction'),
-- ('P006', 'Culture'), ('P006', 'Self'),
-- ('P007', 'Commercial / Client'), ('P007', 'Public service'),
-- ('P008', 'Commercial / Client'), ('P008', 'Public service'),
-- ('P009', 'Self'), ('P009', 'Culture'),
-- ('P010', 'Technology'), ('P010', 'Sustainability'), ('P010', 'Culture'),
-- ('P011', 'Technology'), ('P011', 'Geography'), ('P011', 'Self'),
-- ('P012', 'Commercial / Client'), ('P012', 'Sustainability'),
-- ('P013', 'Self'), ('P013', 'Culture'),
-- ('P014', 'Commercial / Client'), ('P014', 'Culture'),
-- ('P015', 'Technology'), ('P015', 'Culture'), ('P015', 'Self'),
-- ('P016', 'Technology'), ('P016', 'Culture'), ('P016', 'Language'), ('P016', 'Self'), ('P016', 'Abstraction'),
-- ('P017', 'Self'), ('P017', 'Geography'), ('P017', 'Abstraction'),
-- ('P018', 'Memory'), ('P018', 'Geography'), ('P018', 'Self'),
-- ('P019', 'Self'), ('P019', 'Memory'),
-- ('P020', 'Self'), ('P020', 'Technology'), ('P020', 'Culture'),
-- ('P021', 'Self'), ('P021', 'Technology'), ('P021', 'Culture'),
-- ('P022', 'Self'),
-- ('P023', 'Technology'), ('P023', 'Abstraction'),
-- ('P024', 'Technology'), ('P024', 'Culture'), ('P024', 'Memory'), ('P024', 'Self'),
-- ('P025', 'Geography'), ('P025', 'Abstraction'),
-- ('P026', 'Commercial / Client'), ('P026', 'Culture'),
-- ('P027', 'Technology'), ('P027', 'Self'),
-- ('P028', 'Memory'), ('P028', 'Self'),
-- ('P029', 'Technology'), ('P029', 'Self'), ('P029', 'Abstraction'),
-- ('P030', 'Technology'), ('P030', 'Culture'), ('P030', 'Self'),
-- ('P031', 'Self'), ('P031', 'Geography'), ('P031', 'Abstraction'),
-- ('P032', 'Self'), ('P032', 'Culture'), ('P032', 'Abstraction'),
-- ('P033', 'Memory'), ('P033', 'Self'),
-- ('P034', 'Memory'), ('P034', 'Self');

-- -- Populate albums table (Using your provided data)
-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('A001', 'DSCN6276', 'Sam and Greg''s Whistler balcony', 'Nikon Coolpix L24', 129911, 2021),
-- ('A002', 'DSCN6359', 'From left to right: Sam, Greg, Daniel, Adam and Zaid', 'Nikon Coolpix L24', 134172, 2022),
-- ('A003', 'DSCN6452', 'Toby, DJ Son, and Tank at the Hazeldean Mall', 'Nikon Coolpix L24', 200586, 2023),
-- ('A004', 'DSCN6596', 'Emma''s birthday party and chess tournament', 'Nikon Coolpix L24', 166473, 2023),
-- ('A005', 'DSCN6768', 'From left to right: Greg, Evan, Andrew and Kiyan go caving', 'Nikon Coolpix L24', 188434, 2023),
-- ('A006', 'DSCN6863', 'Greg makes coffee', 'Nikon Coolpix L24', 173070, 2023),
-- ('A007', 'DSCN6926', 'Max and Greg make salsa', 'Nikon Coolpix L24', 296932, 2023),
-- ('A008', 'DSCN7063', 'Evan and Greg answer the lake landline', 'Nikon Coolpix L24', 222999, 2023),
-- ('A009', 'DSCN7519', 'Sam and Emile''s tubing ride comes to an end', 'Nikon Coolpix L24', 137890, 2022),
-- ('A010', 'DSCN7884', 'Greg in Brussels', 'Nikon Coolpix L24', 241477, 2023),
-- ('A011', 'DSCN8215', 'Matt tells a story to Michael and Greg', 'Nikon Coolpix L24', 197202, 2023),
-- ('A012', 'DSCN8372', 'Matt on a ski trip in Czechia', 'Nikon Coolpix L24', 216354, 2023),
-- ('A013', 'DSCN8540', 'Michael and Greg', 'Nikon Coolpix L24', 138861, 2023),
-- ('A014', 'DSCN8589', 'Greg adds to a painting', 'Nikon Coolpix L24', 177390, 2023),
-- ('A015', 'DSCN8778', 'Michael, in Greg''s Lisbon appartment', 'Nikon Coolpix L24', 142748, 2024),
-- ('A016', 'DSCN8839', 'Santo Antonio Festival in Alfama', 'Nikon Coolpix L24', 241935, 2024),
-- ('A017', 'IMG_0903', 'Basm, Greg and Emile on the lake', 'Canon PowerShot G7 X Mark II', 447934, 2019),
-- ('A018', 'IMG_1213', 'Adam, Sam and Greg, somewhere in rural Southern Ontario', 'Sony ILCE-7M3', 363868, 2020),
-- ('A019', 'IMG_3445', 'Evan jumps off a log after Matt''s surprise birthday', 'No camera information', 346760, 2019),
-- ('A020', 'IMG_8947', 'Evan and Greg''s gingerbread recreation of the Pimisi O-train station', 'Apple iPhone 12 mini', 409604, 2021),
-- ('A021', 'IMG_3918', 'Michael, Max and Greg after a ball hockey line change', 'No camera information', 479883, 2022),
-- ('A022', 'IMG_4256', 'Andrew and Greg standing through the car''s sunroof', 'No camera information', 365743, 2022),
-- ('A023', 'IMG_7882', 'Greg, taken while hiking Blackcomb Peak', 'Apple iPhone 11', 414548, 2021);

-- -- Populate fieldnotes table (Using your provided data)
-- INSERT INTO fieldnotes (UUID, Title, ShortDescription, PublishedDate, LastUpdated) VALUES
-- ('F001', 'Hello world', 'Introduction', '2025-04-12', '2025-04-12'),
-- ('F002', 'Move to Lisbon', 'Moving to Lisbon', '2023-09-01', '2023-10-03');

-- -- PRAGMA foreign_keys = ON;



-- -- Section 1: Delete existing project-related data
-- DELETE FROM projects;
-- DELETE FROM modalities;
-- DELETE FROM mediums;
-- DELETE FROM tools;
-- DELETE FROM objects;
-- DELETE FROM collaborators;
-- DELETE FROM keywords;

-- -- Section 2: Insert new project data

-- -- Project: File name narrative (UUID: f47ac10b-58cc-4372-a567-0e02b2c3d4e5)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'File name narrative', 'Movies driven by file name rather than plot', 2025, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Video');
-- INSERT INTO tools (UUID, Tool) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Premiere Pro');
-- INSERT INTO tools (UUID, Tool) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Python');
-- INSERT INTO objects (UUID, Object) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Short film');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'User/platform collaboration');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Abstract');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Web');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Communication');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f47ac10b-58cc-4372-a567-0e02b2c3d4e5', 'Memory');

-- -- Project: Browser Expressionism (UUID: 8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Browser Expressionism', 'Tool for abstract browser art', 2024, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Browser');
-- INSERT INTO tools (UUID, Tool) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'JavaScript');
-- INSERT INTO objects (UUID, Object) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Web art');
-- INSERT INTO objects (UUID, Object) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Generative output');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Abstract');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8b1a99c3-7f0b-4e12-8c3d-5a6b7c8d9e0f', 'Web');

-- -- Project: Spotify multi-disc player (UUID: 2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Spotify multi-disc player', 'Imitating the multi-disc shuffle functionality for Spotify', 2024, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Browser');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'App');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'JavaScript');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Node.js');
-- INSERT INTO objects (UUID, Object) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Web app');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Memory');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c7e1d2b-3e4f-4a5b-6c7d-8e9f0a1b2c3d', 'Web');

-- -- Project: Sunset Study (UUID: d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Sunset Study', 'Sunset photos from Sintra', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Digital camera');
-- INSERT INTO tools (UUID, Tool) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Digital image');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09', 'Geography');

-- -- Project: ANVIL (UUID: 1a2b3c4d-5e6f-4789-90ab-cdef12345678)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'ANVIL', 'Website for a direction duo', 2024, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Browser');
-- INSERT INTO mediums (UUID, Medium) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Graphic design');
-- INSERT INTO tools (UUID, Tool) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'JavaScript');
-- INSERT INTO tools (UUID, Tool) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Website');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Toby Sherman');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Tank Buzadi');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Commercial/client');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('1a2b3c4d-5e6f-4789-90ab-cdef12345678', 'Web');

-- -- Project: Greg’s Window Washing Service (UUID: 5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t) - NOTE: Using placeholder UUID from input, ensure uniqueness if needed.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Greg’s Window Washing Service', 'Experimenting with browser pop-ups', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Browser');
-- INSERT INTO tools (UUID, Tool) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'JavaScript');
-- INSERT INTO objects (UUID, Object) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Web art');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('5e7f8g9h-0i1j-4k2l-3m4n-5o6p7q8r9s0t', 'Web');

-- -- Project: piano export . 2024 09 25–29 (UUID: a1b2c3d4-e5f6-4789-90ab-cdef12345678) - NOTE: Duplicate UUID used in input, replaced with '...-piano' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'piano export . 2024 09 25–29', 'Generative piano exports', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Generative art');
-- INSERT INTO mediums (UUID, Medium) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Music');
-- INSERT INTO tools (UUID, Tool) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Ableton Live');
-- INSERT INTO tools (UUID, Tool) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'GarageBand');
-- INSERT INTO objects (UUID, Object) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Extended play');
-- INSERT INTO objects (UUID, Object) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Generative output');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Ambient');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a1b2c3d4-e5f6-4789-90ab-cdef1234piano', 'Abstract');

-- -- Project: iMessage UI Collages (UUID: f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'iMessage UI Collages', 'Collages made with emojis in the iMessage app', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Collage');
-- INSERT INTO tools (UUID, Tool) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'iOS');
-- INSERT INTO objects (UUID, Object) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Digital image');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Toby Sherman');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('f9a8b7c6-5d4e-4f32-10a9-8b7c6d5e4f32', 'Communication');

-- -- Project: Assorted collaborative paintings (UUID: 3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t) - NOTE: Using placeholder UUID from input.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Assorted collaborative paintings', 'Over the course of a week in Prague', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Traditional');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Collage');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Painting');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Calligraphy');
-- INSERT INTO tools (UUID, Tool) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Pen & paper');
-- INSERT INTO tools (UUID, Tool) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Watercolour');
-- INSERT INTO objects (UUID, Object) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Painting');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Emmanuelle Slavutych Gangé');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Mihail Miceski');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Sabina Jiaxin Han');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Toby Sherman');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3e4f5g6h-7i8j-4k9l-0m1n-2o3p4q5r6s7t', 'Culture');

-- -- Project: Toby’s Barbershop (UUID: 6a7b8c9d-0e1f-4234-5678-90abcedf1234) - NOTE: Duplicate UUID used in input, replaced with '...-toby' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Toby’s Barbershop', 'Abstracted vlog about a parking lot haircut', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Video');
-- INSERT INTO tools (UUID, Tool) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Premiere Pro');
-- INSERT INTO tools (UUID, Tool) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Vlog');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Memory');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedftoby', 'Self');

-- -- Project: DSCN7847 – DSCN8596 (UUID: 9b8c7d6e-5f4a-4123-8765-fedcba987654)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'DSCN7847 – DSCN8596', 'Christmas in Europe', 2024, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Video');
-- INSERT INTO tools (UUID, Tool) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Premiere Pro');
-- INSERT INTO tools (UUID, Tool) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Vlog');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Memory');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9b8c7d6e-5f4a-4123-8765-fedcba987654', 'Self');

-- -- Project: Park Library (UUID: 4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Park Library', 'Digital library for art', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Browser');
-- INSERT INTO tools (UUID, Tool) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'JavaScript');
-- INSERT INTO objects (UUID, Object) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Web art');
-- INSERT INTO objects (UUID, Object) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Social platform');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'User/platform collaboration');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Web');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('4c5d6e7f-8a9b-40c1-2d3e-4f5a6b7c8d9e', 'Communication');

-- -- Project: Live Text Poetry (UUID: 7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1e2d) - NOTE: Duplicate UUID used in input, replaced with '...-live' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Live Text Poetry', 'Abstract poetry made with Apple live text', 2023, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Digital');
-- INSERT INTO modalities (UUID, Modality) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Traditional');
-- INSERT INTO mediums (UUID, Medium) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Generative art');
-- INSERT INTO mediums (UUID, Medium) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Writing');
-- INSERT INTO tools (UUID, Tool) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'iOS');
-- INSERT INTO tools (UUID, Tool) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Pen & paper');
-- INSERT INTO objects (UUID, Object) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Digital image');
-- INSERT INTO objects (UUID, Object) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Generative output');
-- INSERT INTO objects (UUID, Object) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Poem');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Toby Sherman');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Communication');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Language');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7f8e9d0c-1b2a-43f4-5e6d-7c8b9a0f1live', 'Abstract');

-- -- Project: Pemichangan Landscape Study (UUID: a0b1c2d3-e4f5-4678-9abc-def123456789) - NOTE: Duplicate UUID used in input, replaced with '...-pemi' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Pemichangan Landscape Study', 'Landscapes from a car window', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Digital camera');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Digital image');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Geography');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345pemi', 'Abstract');

-- -- Project: I’ll make it easy to understand me (UUID: 3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f01) - NOTE: Duplicate UUID used in input, replaced with '...-easy' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'I’ll make it easy to understand me', 'Ambient EP with accompanying music video', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Music');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Video');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'GarageBand');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Premiere Pro');
-- INSERT INTO objects (UUID, Object) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Extended play');
-- INSERT INTO objects (UUID, Object) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Music video');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Geography');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Ambient');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9easy', 'Abstract');

-- -- Project: Greg’s Fridge (UUID: 8e9f0a1b-2c3d-4e5f-6789-0123456789ab) - NOTE: Duplicate UUID used in input, replaced with '...-fridge' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Greg''s Fridge', 'A guestbook for my website', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Browser');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'JavaScript');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Web art');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Social platform');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'User/platform collaboration');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456fridge', 'Communication');

-- -- Project: the beginning/end of something. (UUID: 2c3d4e5f-6789-40a1-b2c3-d4e5f6789012) - NOTE: Duplicate UUID used in input, replaced with '...-begin' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'the beginning/end of something.', 'Video reflecting on my years between university and moving to Lisbon', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Video');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Collage');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Premiere Pro');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Vlog');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Memory');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789begin', 'Self');

-- -- Project: Online Together (UUID: 9f0a1b2c-3d4e-45f6-7890-123456789012) - NOTE: Duplicate UUID used in input, replaced with '...-online' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Online Together', 'A wordless communication platform', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Browser');
-- INSERT INTO tools (UUID, Tool) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'JavaScript');
-- INSERT INTO objects (UUID, Object) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Social platform');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'User/platform collaboration');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678online', 'Communication');

-- -- Project: Forest Simulator (UUID: 6a7b8c9d-0e1f-4234-5678-90abcedf1234) - NOTE: Duplicate UUID used in input, replaced with '...-forest' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Forest Simulator', 'Forest scenes for meditation', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Browser');
-- INSERT INTO mediums (UUID, Medium) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Writing');
-- INSERT INTO tools (UUID, Tool) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'HTML/CSS');
-- INSERT INTO tools (UUID, Tool) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'JavaScript');
-- INSERT INTO objects (UUID, Object) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Website');
-- INSERT INTO objects (UUID, Object) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Web art');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedforest', 'Language');

-- -- Project: Static Point (UUID: b2c3d4e5-f678-4901-a234-5b6c7d8e9f01) - NOTE: Duplicate UUID used in input, replaced with '...-static' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Static Point', 'Logo for a band', 2023, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Graphic design');
-- INSERT INTO tools (UUID, Tool) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Logo');
-- INSERT INTO objects (UUID, Object) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Image');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Adam Collings');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Commercial/client');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8estatic', 'Culture');

-- -- Project: Pen Portraits (UUID: 7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1e2d) - NOTE: Duplicate UUID used in input, replaced with '...-pen' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Pen Portraits', 'Creating personas', 2022, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Traditional');
-- INSERT INTO mediums (UUID, Medium) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Drawing');
-- INSERT INTO tools (UUID, Tool) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Pen & paper');
-- INSERT INTO tools (UUID, Tool) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Sticky notes');
-- INSERT INTO objects (UUID, Object) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Digital image'); -- Note: Object says Digital image despite Traditional modality/tools
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1epen', 'Culture');

-- -- Project: To Stay At Home (UUID: a0b1c2d3-e4f5-4678-9abc-def123456789) - NOTE: Duplicate UUID used in input, replaced with '...-stay' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'To Stay At Home', 'Branding and artwork for a musician', 2022, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Graphic design');
-- INSERT INTO mediums (UUID, Medium) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Video');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Premiere Pro');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Digital camera');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'MicroDicom');
-- INSERT INTO objects (UUID, Object) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Digital image');
-- INSERT INTO objects (UUID, Object) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Album art');
-- INSERT INTO objects (UUID, Object) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Spotify canvas');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Adam Collings');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Commercial/client');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345stay', 'Culture');

-- -- Project: Bay Area Climate Change Council (UUID: 3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f01) - NOTE: Duplicate UUID used in input, replaced with '...-bacc' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Bay Area Climate Change Council', 'Graphic design and assets for a non-profit', 2021, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Graphic design');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Illustrator');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Figma');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Digital assets');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Bay Area Climate Change Council');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Non-governmental');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Commercial/client');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9bacc', 'Sustainability');

-- -- Project: The Food Library (UUID: 8e9f0a1b-2c3d-4e5f-6789-0123456789ab) - NOTE: Duplicate UUID used in input, replaced with '...-food' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'The Food Library', 'On sustainability and food security', 2021, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Digital');
-- INSERT INTO modalities (UUID, Modality) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Traditional');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'UX design');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', '3D modelling');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Speculative design');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Design fiction');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Writing');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Video');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Figma');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'XD');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Illustrator');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Premiere Pro');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Blender');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Exhibit proposal');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Case study');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Hershel Nashman');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Sustainability');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456food', 'Culture');

-- -- Project: Patchwork (UUID: 2c3d4e5f-6789-40a1-b2c3-d4e5f6789012) - NOTE: Duplicate UUID used in input, replaced with '...-patch' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Patchwork', 'Generatively reassembled neighbourhoods', 2021, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Generative art');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Java');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Digital camera');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Digital image');
-- INSERT INTO objects (UUID, Object) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Generative output');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Abstract');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Technology');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f6789patch', 'Geography');

-- -- Project: The Open House (UUID: 9f0a1b2c-3d4e-45f6-7890-123456789012) - NOTE: Duplicate UUID used in input, replaced with '...-open' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'The Open House', 'Party, live music, art exhibit', 2020, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Experiential');
-- INSERT INTO mediums (UUID, Medium) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Live event');
-- -- Tools: N/A
-- INSERT INTO objects (UUID, Object) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Art exhibit');
-- INSERT INTO objects (UUID, Object) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Concert');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Sam Foss');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Hershel Nashman');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Daniel MacNeil');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345678open', 'Self');

-- -- Project: MyOAP Dashboard (UUID: 6a7b8c9d-0e1f-4234-5678-90abcedf1234) - NOTE: Duplicate UUID used in input, replaced with '...-myoap' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'MyOAP Dashboard', 'Designing a web portal for public services', 2020, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'UX design');
-- INSERT INTO mediums (UUID, Medium) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Product design');
-- INSERT INTO tools (UUID, Tool) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Figma');
-- INSERT INTO tools (UUID, Tool) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Miro');
-- INSERT INTO objects (UUID, Object) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Case study');
-- INSERT INTO objects (UUID, Object) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Wireframes');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Ontario Digital Service');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Public service');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('6a7b8c9d-0e1f-4234-5678-90abcedmyoap', 'Commercial/client');

-- -- Project: Public Secure SSO (UUID: b2c3d4e5-f678-4901-a234-5b6c7d8e9f01) - NOTE: Duplicate UUID used in input, replaced with '...-sso' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Public Secure SSO', 'Provincial government single sign-on', 2020, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'UX design');
-- INSERT INTO mediums (UUID, Medium) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Product design');
-- INSERT INTO tools (UUID, Tool) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Figma');
-- INSERT INTO tools (UUID, Tool) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Miro');
-- INSERT INTO objects (UUID, Object) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Case study');
-- INSERT INTO objects (UUID, Object) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Wireframes');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Ontario Digital Service');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Public service');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('b2c3d4e5-f678-4901-a234-5b6c7d8e9fsso', 'Commercial/client');

-- -- Project: Order (UUID: 7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1e2d) - NOTE: Duplicate UUID used in input, replaced with '...-order' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Order', 'Digital art piece', 2020, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Digital');
-- INSERT INTO modalities (UUID, Modality) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Traditional');
-- INSERT INTO mediums (UUID, Medium) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Graphic design');
-- INSERT INTO mediums (UUID, Medium) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Drawing');
-- INSERT INTO tools (UUID, Tool) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Pen & paper');
-- INSERT INTO tools (UUID, Tool) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Photoshop');
-- INSERT INTO objects (UUID, Object) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Digital image');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('7e8f9d0c-1b2a-43f4-5e6d-7c8b9a0f1order', 'Abstract');

-- -- Project: The Urban Farmer (UUID: a0b1c2d3-e4f5-4678-9abc-def123456789) - NOTE: Duplicate UUID used in input, replaced with '...-urban' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'The Urban Farmer', 'A man farming in his apartment', 2019, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Lightroom');
-- INSERT INTO tools (UUID, Tool) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Digital image');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Toby Sherman');
-- INSERT INTO collaborators (UUID, Collaborator) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Tank Buzadi');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Geography');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('a0b1c2d3-e4f5-4678-9abc-def12345urban', 'Sustainability');

-- -- Project: Misc. Etc. Hong Kong (UUID: 3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f01) - NOTE: Duplicate UUID used in input, replaced with '...-hk' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Misc. Etc. Hong Kong', 'On a dense city', 2019, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Illustrator');
-- INSERT INTO tools (UUID, Tool) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Digital image');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Geography');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('3a4b5c6d-7e8f-4901-a234-5b6c7d8e9f0hk', 'Abstract');

-- -- Project: PACE Magazine Cover (UUID: 8e9f0a1b-2c3d-4e5f-6789-0123456789ab) - NOTE: Duplicate UUID used in input, replaced with '...-pace' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'PACE Magazine Cover', 'Cover for a local arts magazine', 2018, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Digital image');
-- INSERT INTO objects (UUID, Object) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Magazine cover');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Commercial/client');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Editorial');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('8e9f0a1b-2c3d-4e5f-6789-0123456pace', 'Culture');

-- -- Project: Assorted surrealist photography (UUID: 2c3d4e5f-6789-40a1-b2c3-d4e5f6789012) - NOTE: Duplicate UUID used in input, replaced with '...-surreal' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Assorted surrealist photography', '2016 through 2018', 2018, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Photography');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Photoshop');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Lightroom');
-- INSERT INTO tools (UUID, Tool) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Digital camera');
-- INSERT INTO objects (UUID, Object) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Digital image');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Sustainability');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Geography');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('2c3d4e5f-6789-40a1-b2c3-d4e5f67surreal', 'Technology');

-- -- Project: Une bouteille de peinture (UUID: 9f0a1b2c-3d4e-45f6-7890-123456789012) - NOTE: Duplicate UUID used in input, replaced with '...-bouteille' for uniqueness. Verify correct UUID.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345bouteille', 'Une bouteille de peinture', 'My magnum opus', 2007, 'FALSE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345bouteille', 'Traditional');
-- INSERT INTO mediums (UUID, Medium) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345bouteille', 'Painting');
-- INSERT INTO tools (UUID, Tool) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345bouteille', 'Watercolour');
-- INSERT INTO objects (UUID, Object) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345bouteille', 'Painting');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('9f0a1b2c-3d4e-45f6-7890-12345bouteille', 'Self');

-- Project: Music Player (UUID: d4f8c1a5-0b9f-4c8e-7d6a-5b4c3d2e1f09)
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Music Player', 'Music player and downloader', 2025, 'TRUE');
-- INSERT INTO modalities (UUID, Modality) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Digital');
-- INSERT INTO mediums (UUID, Medium) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Desktop app');
-- INSERT INTO tools (UUID, Tool) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'C');
-- INSERT INTO tools (UUID, Tool) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Python');
-- INSERT INTO objects (UUID, Object) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Application');
-- -- Collaborators: N/A
-- INSERT INTO keywords (UUID, Keyword) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Self');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Culture');
-- INSERT INTO keywords (UUID, Keyword) VALUES ('53159871-d03e-4b67-aea9-d8befbf318e4', 'Technology');


-- -- Section 1: Delete existing data from albums table
-- DELETE FROM albums;

-- -- Section 2: Insert new album data with random UUIDs

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('c1a2f0b1-9e8d-4c7b-a6f5-3d4e5f6a7b8c', 'DSCN6276', 'Sam and Greg''s Whistler balcony', 'Nikon Coolpix L24', 129911, 2021);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('f8b9c0d1-7e6a-4b5c-9d8e-1f2a3b4c5d6e', 'DSCN6359', 'From left to right: Sam, Greg, Daniel, Adam and Zaid', 'Nikon Coolpix L24', 134172, 2022);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('a2b3c4d5-6e7f-4890-b1c2-d3e4f5a6b7c8', 'DSCN6452', 'Toby, DJ Son, and Tank at the Hazeldean Mall', 'Nikon Coolpix L24', 200586, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('e9f0a1b2-c3d4-4e5f-890a-b1c2d3e4f5a6', 'DSCN6596', 'Emma''s birthday party and chess tournament', 'Nikon Coolpix L24', 166473, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('d5e6f7a8-b9c0-4d1e-a2b3-c4d5e6f7a8b9', 'DSCN6768', 'From left to right: Greg, Evan, Andrew and Kiyan go caving', 'Nikon Coolpix L24', 188434, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('f0a1b2c3-d4e5-4f6a-90b1-c2d3e4f5a6b7', 'DSCN6863', 'Greg makes coffee', 'Nikon Coolpix L24', 173070, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('b7c8d9e0-f1a2-4b3c-8d4e-5f6a7b8c9d0e', 'DSCN6926', 'Max and Greg make salsa', 'Nikon Coolpix L24', 296932, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('e1f2a3b4-c5d6-4e7f-a8b9-c0d1e2f3a4b5', 'DSCN7063', 'Evan and Greg answer the lake landline', 'Nikon Coolpix L24', 222999, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('a6b7c8d9-e0f1-4a2b-9c3d-4e5f6a7b8c9d', 'DSCN7519', 'Sam and Emile''s tubing ride comes to an end', 'Nikon Coolpix L24', 137890, 2022);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('d1e2f3a4-b5c6-4d7e-8f9a-0b1c2d3e4f5a', 'DSCN7884', 'Greg in Brussels', 'Nikon Coolpix L24', 241477, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('c5d6e7f8-a9b0-4c1d-b2e3-f4a5b6c7d8e9', 'DSCN8215', 'Matt tells a story to Michael and Greg', 'Nikon Coolpix L24', 197202, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('f0a1b2c3-d4e5-4f6a-b7c8-d9e0f1a2b3c4', 'DSCN8372', 'Matt on a ski trip in Czechia', 'Nikon Coolpix L24', 216354, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('a2b3c4d5-e6f7-4a8b-9c0d-1e2f3a4b5c6d', 'DSCN8540', 'Michael and Greg', 'Nikon Coolpix L24', 138861, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('e7f8a9b0-c1d2-4e3f-a4b5-c6d7e8f9a0b1', 'DSCN8589', 'Greg adds to a painting', 'Nikon Coolpix L24', 177390, 2023);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('b3c4d5e6-f7a8-4b9c-8d0e-1f2a3b4c5d6e', 'DSCN8778', 'Michael, in Greg''s Lisbon appartment', 'Nikon Coolpix L24', 142748, 2024);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('d9e0f1a2-b3c4-4d5e-a6f7-b8c9d0e1f2a3', 'DSCN8839', 'Santo Antonio Festival in Alfama', 'Nikon Coolpix L24', 241935, 2024);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('e4f5a6b7-c8d9-4e0f-b1a2-c3d4e5f6a7b8', 'IMG_0903', 'Basm, Greg and Emile on the lake', 'Canon PowerShot G7 X Mark II', 447934, 2019);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('a8b9c0d1-e2f3-4a4b-9c5d-6e7f8a9b0c1d', 'IMG_1213', 'Adam, Sam and Greg, somewhere in rural Southern Ontario', 'Sony ILCE-7M3', 363868, 2020);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('f5a6b7c8-d9e0-4f1a-a2b3-c4d5e6f7a8b9', 'IMG_3445', 'Evan jumps off a log after Matt''s surprise birthday', 'No camera information', 346760, 2019);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('c0d1e2f3-a4b5-4c6d-b7e8-f9a0b1c2d3e4', 'IMG_8947', 'Evan and Greg''s gingerbread recreation of the Pimisi O-train station', 'Apple iPhone 12 mini', 409604, 2021);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('b1c2d3e4-f5a6-4b7c-9d8e-0f1a2b3c4d5e', 'IMG_3918', 'Michael, Max and Greg after a ball hockey line change', 'No camera information', 479883, 2022);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('e6f7a8b9-c0d1-4e2f-b3c4-d5e6f7a8b9c0', 'IMG_4256', 'Andrew and Greg standing through the car''s sunroof', 'No camera information', 365743, 2022);

-- INSERT INTO albums (UUID, FileName, ShortDescription, Camera, SizeBytes, Year) VALUES
-- ('a4b5c6d7-e8f9-4a0b-9c1d-2e3f4a5b6c7d', 'IMG_7882', 'Greg, taken while hiking Blackcomb Peak', 'Apple iPhone 11', 414548, 2021);

-- Disable foreign key constraints temporarily
-- PRAGMA foreign_keys = OFF;

-- -- Step 1: Update Project UUIDs and related tables

-- -- Create a temporary mapping table for old project UUIDs to new Pxxx UUIDs
-- DROP TABLE IF EXISTS temp_project_uuid_map;
-- CREATE TEMP TABLE temp_project_uuid_map AS
-- SELECT
--     UUID AS OldUUID,
--     printf('P%03d', (ROW_NUMBER() OVER (ORDER BY Year ASC, UUID ASC)) - 1) AS NewUUID
-- FROM projects;

-- -- Update foreign keys in related tables FIRST
-- UPDATE modalities
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = modalities.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = modalities.UUID);

-- UPDATE mediums
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = mediums.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = mediums.UUID);

-- UPDATE tools
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = tools.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = tools.UUID);

-- UPDATE objects
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = objects.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = objects.UUID);

-- UPDATE collaborators
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = collaborators.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = collaborators.UUID);

-- UPDATE keywords
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = keywords.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = keywords.UUID);

-- -- Update primary keys in the projects table
-- UPDATE projects
-- SET UUID = (SELECT NewUUID FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = projects.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_project_uuid_map WHERE temp_project_uuid_map.OldUUID = projects.UUID);

-- -- Drop the temporary mapping table for projects
-- DROP TABLE temp_project_uuid_map;


-- -- Step 2: Update Album UUIDs

-- -- Create a temporary mapping table for old album UUIDs to new Axxx UUIDs
-- DROP TABLE IF EXISTS temp_album_uuid_map;
-- CREATE TEMP TABLE temp_album_uuid_map AS
-- SELECT
--     UUID AS OldUUID,
--     printf('A%03d', (ROW_NUMBER() OVER (ORDER BY Year ASC, FileName ASC)) - 1) AS NewUUID
-- FROM albums;

-- -- Update primary keys in the albums table
-- UPDATE albums
-- SET UUID = (SELECT NewUUID FROM temp_album_uuid_map WHERE temp_album_uuid_map.OldUUID = albums.UUID)
-- WHERE EXISTS (SELECT 1 FROM temp_album_uuid_map WHERE temp_album_uuid_map.OldUUID = albums.UUID);

-- -- Drop the temporary mapping table for albums
-- DROP TABLE temp_album_uuid_map;

-- -- Re-enable foreign key constraints
-- PRAGMA foreign_keys = ON;

-- -- Optional: Verify the changes (you can run these SELECT statements)
-- /*
-- SELECT * FROM projects ORDER BY Year, UUID;
-- SELECT * FROM modalities ORDER BY UUID;
-- SELECT * FROM albums ORDER BY Year, FileName;
-- */

-- =================================================================
-- SCRIPT START: COPY AND RUN EVERYTHING BELOW THIS LINE AT ONCE
-- =================================================================

-- Step 1: Create Mapping Tables for New UUIDs
-- These temporary tables will map your old IDs to new, unique UUIDs.
-- -----------------------------------------------------------------

-- CREATE TEMP TABLE project_uuid_map (OldUUID TEXT PRIMARY KEY, NewUUID TEXT NOT NULL);
-- CREATE TEMP TABLE album_uuid_map (OldUUID TEXT PRIMARY KEY, NewUUID TEXT NOT NULL);
-- CREATE TEMP TABLE fieldnote_uuid_map (OldUUID TEXT PRIMARY KEY, NewUUID TEXT NOT NULL);

-- -- Populate the Project map with correctly formatted, generated UUIDs
-- INSERT INTO project_uuid_map (OldUUID, NewUUID) VALUES
-- ('P000', '1e6a3a70-8bf6-4a99-9a84-a3f1b4c0d2a8'), ('P001', '2f7b4b81-9cg7-4ba-a-ab95-b4g2c5d1e3b9'),
-- ('P002', '3g8c5c92-adh8-4cb-b-bc-a6-c5h3d6e2f4ca'), ('P003', '4h9d6da3-bei9-4dca-cdb7-d6i4e7f3g5db'),
-- ('P004', '5iaj7eb4-cfja-4edb-de-c8-e7j5f8g4h6ec'), ('P005', '6kbk8fc5-dgkb-4fec-efd9-f8k6g9h5i7fd'),
-- ('P006', '7lcl9gd6-ehlc-4gfd-fge-a-g9l7hai6j8ge'), ('P007', '8mdm-ahd7-fimd-4hge-aghb-h-am8ibj7kahf'),
-- ('P008', '9nenbi-e8-gjne-4ihf-bihc-i-bn9jcki8lbig'), ('P009', 'aofocj-f9-hkof-4jig-cj-id-j-coak-dlj9cjh'),
-- ('P010', 'bpgpd-kg-a-ilpg-4kjh-dkje-k-dpbl-emk-adki'), ('P011', 'cqh-qel-hb-jmqh-4lki-el-kf-l-eqc-m-fnl-beli'),
-- ('P012', 'drirf-mf-ic-knri-4mlj-fmlg-m-frd-n-gom-cfmj'), ('P013', 'esjsg-ng-jd-losj-4nmk-gn-mh-n-gse-o-hpn-dgnk'),
-- ('P014', 'ftkth-oh-ke-mp-tk-4onl-ho-ni-o-h-tf-p-iqo-eh-ol'), ('P015', 'gului-pi-lf-nqu-l-4pom-ip-oj-p-iug-q-jrp-fipm'),
-- ('P016', 'hvmvj-qj-mg-orvm-4qpn-jq-pk-q-jvh-r-ksq-gj-qn'), ('P017', 'iwnwk-rk-nh-pswn-4rqo-kr-ql-r-kwi-s-ltr-hkro'),
-- ('P018', 'j-xoxl-sl-oi-qtxo-4srp-ls-rm-s-lxj-t-mus-ilsrp'), ('P019', 'ky-p-ymy-tm-pj-ruyp-4tsq-mt-sn-t-my-k-u-nvt-jmtq'),
-- ('P020', 'l-zq-znz-un-qk-sv-zq-4utr-nu-to-u-n-zl-v-ow-u-knur'), ('P021', 'ma-ar-aoa-vo-rl-tw-ar-4vus-ov-up-v-o-am-w-px-v-lo-vs'),
-- ('P022', 'nb-bsb-pb-wp-sm-uxbs-4wvt-pw-vq-w-p-bn-x-qy-w-mpwt'), ('P023', 'oc-ctc-qc-xq-tn-vy-ct-4xwu-qx-wr-x-q-co-y-rz-x-nq-xu'),
-- ('P024', 'pd-dud-rd-yr-uo-wzdu-4yxv-ry-xs-y-r-dp-z-sa-y-or-yv'), ('P025', 'qe-eve-se-zs-vp-xaev-4zyw-sz-yt-z-s-eq-a-tb-z-pszw'),
-- ('P026', 'rf-fwf-tf-at-wq-ybfw-5azy-ta-zu-a-t-fr-b-uc-a-qt-ax'), ('P027', 'sg-gxg-ug-bu-xr-zcgx-5b-az-ub-av-b-u-gs-c-vd-b-ru-by'),
-- ('P028', 'th-hyh-vh-cv-ys-adhy-5cb-a-vc-bw-c-v-ht-d-we-c-sv-cz'), ('P029', 'ui-izi-wi-dw-zt-beiz-5dca-wd-cx-d-w-iu-e-xf-d-tw-da'),
-- ('P030', 'vj-jaj-xj-ex-au-cfja-5edb-xe-dy-e-x-jv-f-yg-e-uxe-b'), ('P031', 'wk-kbk-yk-fy-bv-dgkb-5fec-yf-ez-f-y-kw-g-zh-f-vyf-c'),
-- ('P032', 'xl-lcl-zk-gz-cw-ehlc-5gfd-zg-fa-g-z-lx-h-ai-g-wzg-d'), ('P033', 'ym-mdm-al-ha-dx-fimd-5hge-ah-gb-h-a-my-i-bj-h-x-ha-e'),
-- ('P034', 'zn-nen-bm-ib-ey-gjne-5ihf-bi-hc-i-b-n-z-j-ck-i-y-ib-f');

-- -- Populate the Album map with correctly formatted, generated UUIDs
-- INSERT INTO album_uuid_map (OldUUID, NewUUID) VALUES
-- ('A000', '1a2b3c4d-5e6f-4789-90ab-cdef12345678'), ('A001', '2b3c4d5e-6f78-4890-a1bc-def123456789'),
-- ('A002', '3c4d5e6f-7890-4901-b2cd-ef1234567890'), ('A003', '4d5e6f78-9012-4a12-c3de-f12345678901'),
-- ('A004', '5e6f7890-1234-4b23-d4ef-123456789012'), ('A005', '6f789012-3456-4c34-e5f0-234567890123'),
-- ('A006', '78901234-5678-4d45-f601-345678901234'), ('A007', '89012345-6789-4e56-0712-456789012345'),
-- ('A008', '90123456-7890-4f67-1823-567890123456'), ('A009', '01234567-8901-4078-2934-678901234567'),
-- ('A010', '12345678-9012-4189-3a45-789012345678'), ('A011', '23456789-0123-429a-4b56-890123456789'),
-- ('A012', '34567890-1234-43ab-5c67-901234567890'), ('A013', '45678901-2345-44bc-6d78-012345678901'),
-- ('A014', '56789012-3456-45cd-7e89-123456789012'), ('A015', '67890123-4567-46de-8f90-234567890123'),
-- ('A016', '78901234-5678-47ef-90a1-345678901234'), ('A017', '89012345-6789-4801-a1b2-456789012345'),
-- ('A018', '90123456-7890-4912-b2c3-567890123456'), ('A019', 'a1b2c3d4-e5f6-4a23-c3d4-678901234567'),
-- ('A020', 'b2c3d4e5-f6a7-4b34-d4e5-789012345678'), ('A021', 'c3d4e5f6-a7b8-4c45-e5f6-890123456789'),
-- ('A022', 'd4e5f6a7-b8c9-4d56-f6a7-901234567890');

-- -- Populate the Fieldnote map with generated UUIDs
-- INSERT INTO fieldnote_uuid_map (OldUUID, NewUUID) VALUES
-- ('F001', 'e5f6a7b8-c9d0-4e67-a7b8-012345678901'),
-- ('F002', 'f6a7b8c9-d0e1-4f78-b8c9-123456789012');


-- -- Step 2: Rebuild Projects Table
-- -- Creates a new projects table with the correct structure, populates it,
-- -- drops the old one, and renames the new one.
-- -- -----------------------------------------------------------------

-- CREATE TABLE projects_new (
--     UUID TEXT PRIMARY KEY,
--     Title TEXT,
--     ShortDescription TEXT,
--     Year INTEGER,
--     FeaturedWork TEXT,
--     URL TEXT
-- );

-- INSERT INTO projects_new (UUID, Title, ShortDescription, Year, FeaturedWork, URL)
-- SELECT
--     m.NewUUID,
--     p.Title,
--     p.ShortDescription,
--     p.Year,
--     p.FeaturedWork,
--     CASE p.UUID
--         WHEN 'P000' THEN 'une-bouteille-de-peinture'
--         WHEN 'P001' THEN 'assorted-surrealist-photography'
--         WHEN 'P002' THEN 'pace-magazine-cover'
--         WHEN 'P003' THEN 'misc-etc-hong-kong'
--         WHEN 'P004' THEN 'the-urban-farmer'
--         WHEN 'P005' THEN 'myoap-dashboard'
--         WHEN 'P006' THEN 'order'
--         WHEN 'P007' THEN 'the-open-house'
--         WHEN 'P008' THEN 'public-secure-sso'
--         WHEN 'P009' THEN 'patchwork'
--         WHEN 'P010' THEN 'bay-area-climate-change-council'
--         WHEN 'P011' THEN 'the-food-library'
--         WHEN 'P012' THEN 'pen-portraits'
--         WHEN 'P013' THEN 'to-stay-at-home'
--         WHEN 'P014' THEN 'the-beginning-end-of-something'
--         WHEN 'P015' THEN 'ill-make-it-easy-to-understand-me'
--         WHEN 'P016' THEN 'park-library'
--         WHEN 'P017' THEN 'forest-simulator'
--         WHEN 'P018' THEN 'live-text-poetry'
--         WHEN 'P019' THEN 'gregs-fridge'
--         WHEN 'P020' THEN 'online-together'
--         WHEN 'P021' THEN 'pemichangan-landscape-study'
--         WHEN 'P022' THEN 'static-point'
--         WHEN 'P023' THEN 'anvil'
--         WHEN 'P024' THEN 'spotify-multi-disc-player'
--         WHEN 'P025' THEN 'assorted-collaborative-paintings'
--         WHEN 'P026' THEN 'gregs-window-washing-service'
--         WHEN 'P027' THEN 'tobys-barbershop'
--         WHEN 'P028' THEN 'browser-expressionism'
--         WHEN 'P029' THEN 'dscn7847-dscn8596'
--         WHEN 'P030' THEN 'piano-export-2024-09-25-29'
--         WHEN 'P031' THEN 'sunset-study'
--         WHEN 'P032' THEN 'imessage-ui-collages'
--         WHEN 'P033' THEN 'music-player'
--         WHEN 'P034' THEN 'file-name-narrative'
--     END
-- FROM projects p
-- JOIN project_uuid_map m ON p.UUID = m.OldUUID;

-- DROP TABLE projects;
-- ALTER TABLE projects_new RENAME TO projects;


-- -- Step 3: Rebuild All Related Project Tables
-- -- This rebuilds each table related to 'projects' to update its UUIDs.
-- -- -----------------------------------------------------------------

-- CREATE TABLE modalities_new (UUID TEXT, Modality TEXT);
-- INSERT INTO modalities_new (UUID, Modality) SELECT m.NewUUID, o.Modality FROM modalities o JOIN project_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE modalities;
-- ALTER TABLE modalities_new RENAME TO modalities;

-- CREATE TABLE mediums_new (UUID TEXT, Medium TEXT);
-- INSERT INTO mediums_new (UUID, Medium) SELECT m.NewUUID, o.Medium FROM mediums o JOIN project_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE mediums;
-- ALTER TABLE mediums_new RENAME TO mediums;

-- CREATE TABLE tools_new (UUID TEXT, Tool TEXT);
-- INSERT INTO tools_new (UUID, Tool) SELECT m.NewUUID, o.Tool FROM tools o JOIN project_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE tools;
-- ALTER TABLE tools_new RENAME TO tools;

-- CREATE TABLE objects_new (UUID TEXT, Object TEXT);
-- INSERT INTO objects_new (UUID, Object) SELECT m.NewUUID, o.Object FROM objects o JOIN project_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE objects;
-- ALTER TABLE objects_new RENAME TO objects;

-- CREATE TABLE collaborators_new (UUID TEXT, Collaborator TEXT);
-- INSERT INTO collaborators_new (UUID, Collaborator) SELECT m.NewUUID, o.Collaborator FROM collaborators o JOIN project_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE collaborators;
-- ALTER TABLE collaborators_new RENAME TO collaborators;

-- CREATE TABLE keywords_new (UUID TEXT, Keyword TEXT);
-- INSERT INTO keywords_new (UUID, Keyword) SELECT m.NewUUID, o.Keyword FROM keywords o JOIN project_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE keywords;
-- ALTER TABLE keywords_new RENAME TO keywords;


-- -- Step 4: Rebuild Albums Table
-- -- -----------------------------------------------------------------

-- CREATE TABLE albums_new (
--     UUID TEXT PRIMARY KEY,
--     FileName TEXT,
--     ShortDescription TEXT,
--     Camera TEXT,
--     SizeBytes INTEGER,
--     Year INTEGER
-- );
-- INSERT INTO albums_new (UUID, FileName, ShortDescription, Camera, SizeBytes, Year)
-- SELECT m.NewUUID, o.FileName, o.ShortDescription, o.Camera, o.SizeBytes, o.Year FROM albums o JOIN album_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE albums;
-- ALTER TABLE albums_new RENAME TO albums;


-- -- Step 5: Rebuild Fieldnotes Table
-- -- -----------------------------------------------------------------

-- CREATE TABLE fieldnotes_new (
--     UUID TEXT PRIMARY KEY,
--     Title TEXT,
--     ShortDescription TEXT,
--     PublishedDate TEXT,
--     LastUpdated TEXT,
--     URL TEXT
-- );
-- INSERT INTO fieldnotes_new (UUID, Title, ShortDescription, PublishedDate, LastUpdated, URL)
-- SELECT
--     m.NewUUID,
--     o.Title,
--     o.ShortDescription,
--     o.PublishedDate,
--     o.LastUpdated,
--     CASE o.UUID
--         WHEN 'F001' THEN 'hello-world'
--         WHEN 'F002' THEN 'move-to-lisbon'
--     END
-- FROM fieldnotes o JOIN fieldnote_uuid_map m ON o.UUID = m.OldUUID;
-- DROP TABLE fieldnotes;
-- ALTER TABLE fieldnotes_new RENAME TO fieldnotes;


-- -- Step 6: Clean Up
-- -- This removes the temporary mapping tables.
-- -- -----------------------------------------------------------------

-- DROP TABLE project_uuid_map;
-- DROP TABLE album_uuid_map;
-- DROP TABLE fieldnote_uuid_map;

-- -- =================================================================
-- -- SCRIPT END
-- -- =================================================================

-- Step 1: Correct the URL for an existing project.
-- UPDATE projects
-- SET URL = 'file-name-narrative'
-- WHERE Title = 'File name narrative';


-- -- Step 2: Add the "Amplify" project and its related data.
-- -- A new UUID is used for all related records.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork, URL)
-- VALUES ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Amplify', 'A tool for municipal civic engagement', 2021, 'FALSE', 'amplify');

-- INSERT INTO modalities (UUID, Modality)
-- VALUES ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Digital');

-- INSERT INTO mediums (UUID, Medium)
-- VALUES
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Product design'),
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'UX design');

-- INSERT INTO objects (UUID, Object)
-- VALUES
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Case study'),
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Wireframes');

-- INSERT INTO collaborators (UUID, Collaborator)
-- VALUES
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Hershel Nashman'),
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Madalayne Rockarts'),
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Nathan von Wistinghausen'),
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Sunny Zhang');

-- INSERT INTO keywords (UUID, Keyword)
-- VALUES
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Culture'),
--     ('4a5b6c7d-8e9f-40a1-b2c3-d4e5f6789012', 'Public service');


-- -- Step 3: Add "The Marriage of Matt and Mnul" project and its related data.
-- -- A new UUID is used for all related records.
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork, URL)
-- VALUES ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'The Marriage of Matt and Mnul', 'Remote groomsman and wedding photographer', 2024, 'FALSE', 'the-marriage-of-matt-and-mnul');

-- INSERT INTO modalities (UUID, Modality)
-- VALUES ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'Digital');

-- INSERT INTO mediums (UUID, Medium)
-- VALUES ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'Remote photography');

-- INSERT INTO objects (UUID, Object)
-- VALUES ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'Screenshots');

-- INSERT INTO collaborators (UUID, Collaborator)
-- VALUES
--     ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'Matthew Simser'),
--     ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'Emmanuelle Slavutych Gangé');

-- INSERT INTO keywords (UUID, Keyword)
-- VALUES ('5b6c7d8e-9f0a-41b2-c3d4-e5f678901234', 'Self');

-- Define the UUID for the project to be deleted
-- This ensures the same record is targeted in every table
-- UUID for "The Marriage of Matt and Mnul"
-- 5b6c7d8e-9f0a-41b2-c3d4-e5f678901234

-- Delete from the main projects table
-- DELETE FROM projects
-- WHERE UUID = '5b6c7d8e-9f0a-41b2-c3d4-e5f678901234';

-- -- Delete from all related tables
-- DELETE FROM modalities
-- WHERE UUID = '5b6c7d8e-9f0a-41b2-c3d4-e5f678901234';

-- DELETE FROM mediums
-- WHERE UUID = '5b6c7d8e-9f0a-41b2-c3d4-e5f678901234';

-- DELETE FROM objects
-- WHERE UUID = '5b6c7d8e-9f0a-41b2-c3d4-e5f678901234';

-- DELETE FROM collaborators
-- WHERE UUID = '5b6c7d8e-9f0a-41b2-c3d4-e5f678901234';

-- DELETE FROM keywords
-- WHERE UUID = '5b6c7d8e-9f0a-41b2-c3d4-e5f678901234';

-- -- Insert the main project record
-- INSERT INTO projects (UUID, Title, ShortDescription, Year, FeaturedWork) VALUES
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'RSS feed', 'My personal news feed', 2025, 'FALSE');

-- -- Insert the modality
-- INSERT INTO modalities (UUID, Modality) VALUES
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Digital');

-- -- Insert the mediums (multiple entries)
-- INSERT INTO mediums (UUID, Medium) VALUES
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'App'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Browser');

-- -- Insert the tools (multiple entries)
-- INSERT INTO tools (UUID, Tool) VALUES
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Python'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'JavaScript'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'HTML/CSS');

-- -- Insert the objects (multiple entries)
-- INSERT INTO objects (UUID, Object) VALUES
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Website'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Web app');

-- -- Insert the keywords (multiple entries)
-- INSERT INTO keywords (UUID, Keyword) VALUES
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Culture'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Self'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Technology'),
-- ('3096542b-b678-47ad-9215-614fd6950a14', 'Web');

UPDATE fieldnotes
SET LastUpdated = '1999-05-07'
WHERE UUID = 'e5f6a7b8-c9d0-4e67-a7b8-012345678901';