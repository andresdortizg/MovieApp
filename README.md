# MovieApp

Es un proyecto de prueba con la base de datos de peliculas. Se desarrollo usando patron modelo vista controlador MVC. Las vistas fueron creadas programaticamente (Sin Storyboard)

Para el modelo se crearon las clases MTAMovie.swift, MTASearch.swift, MTADateRange.swift, MTAMedia.swift y MTAVideo.swift con los campos descritos por la Api y con cualidad codable para encode y decode. De esta manera su serializacion a JSON y viceversa es rapida y sencilla.

Los Controladores son 2 y se describen a continuacion MTAMoviesHomecontrola los listados de peliculas segun su categoria (Popular y Top Rated)

MTAMovieDetailedViewController para la vista detallada que se incluye un plot (overview) mas extenso. Un video que puede reproducirse en fullscreen. Y 1 boton o ir a comprar en Amazon (sin funcionalidad, era solo por motivos esteticos).

Para persistencia se uso archivos .json con el FileManager. Al correr la app por primera vez se crean los directorios donde se persistiran los archivos. Los nombres de los archivos tendra el campo id concatenado con .json

Para la carga asincrona de imagenes se uso

pod 'Alamofire', '~> 4.7'
pod 'SDWebImage', '~> 4.0'

Mejorando la experiencia de usuario y permitiendo guardar en cache las imagenes hasta un limite de 10MB. Pudiendo asi ver las imagenes incluso sin conexion a internet.

Para reproducir videos de youtube su uso el framework

'YouTubePlayer.framework'

Que permite reproduccion en pantalla completa y tienes controles in screen. No esta permitido la reproduccion offline 

Para detectar el estado de conexion se uso

pod 'ReachabilitySwift'
Este helper permite detectar si hay conexión a internet y de cual tipo. tambien permite detectar sino hay conexión

Se crearon 3 singletone para su uso en toda la App

RPIMovieLoader para cargar data

RPIMovieStorage para la persistencia

RPIReachability para determinar la conexion a internet.


