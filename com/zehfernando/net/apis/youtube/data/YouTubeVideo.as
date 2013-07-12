package com.zehfernando.net.apis.youtube.data {
	import com.zehfernando.net.apis.youtube.YouTubeConstants;
	import com.zehfernando.utils.DateUtils;

	/*FDT_IGNORE*/
	import com.zehfernando.utils.DateUtils;
	/*FDT_IGNORE*/

	/**
	 * @author zeh
	 */
	public class YouTubeVideo {

		// http://gdata.youtube.com/feeds/api/videos/jsvzVFL0Da8

		// Properties
		public var id:String;
		public var published:Date;
		public var updated:Date;
		public var keywords:Vector.<String>;
		public var categories:Vector.<YouTubeCategory>;
		public var title:String;
		public var content:String;
		public var author:String;
		public var comments:int;
		public var thumbnails:Vector.<YouTubeThumbnail>;
		public var duration:Number;
		public var favoriteCount:int;
		public var viewCount:int;

		// Example: http://gdata.youtube.com/feeds/api/videos/PjJnl8UUDzo
		// TODO: add:
		// <media:restriction type='country' relationship='deny'>DE</media:restriction>
		// <media:content url='http://www.youtube.com/v/jsvzVFL0Da8?f=videos&amp;app=youtube_gdata' type='application/x-shockwave-flash' medium='video' isDefault='true' expression='full' duration='55' yt:format='5'/>
		// responses

		// http://code.google.com/apis/youtube/2.0/developers_guide_protocol_api_query_parameters.html

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function YouTubeVideo() {
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getHighestResolutionThumbnailURL():String {
			// Returns the URL of the biggest thumbnail
			var url:String = "";
			var maxWidth:int = 0;

			for (var i:int = 0; i < thumbnails.length; i++) {
				if (thumbnails[i].width > maxWidth) {
					maxWidth = thumbnails[i].width;
					url = thumbnails[i].url;
				}
			}

			return url;
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromXMLList(__xmlList:XMLList): Vector.<YouTubeVideo> {
			var videos:Vector.<YouTubeVideo> = new Vector.<YouTubeVideo>();

			if (!Boolean(__xmlList)) return videos;

			for (var i:int = 0; i < __xmlList.length(); i++) {
				videos.push(YouTubeVideo.fromXML(__xmlList[i]));
			}

			return videos;
		}

		public static function fromXML(__xml:XML): YouTubeVideo {
			// Creates a YouTubeVideo instance from XML parsed from the youtube response

			/*
			<entry xmlns='http://www.w3.org/2005/Atom' xmlns:media='http://search.yahoo.com/mrss/' xmlns:gd='http://schemas.google.com/g/2005' xmlns:yt='http://gdata.youtube.com/schemas/2007'>
				<id>http://gdata.youtube.com/feeds/api/videos/jsvzVFL0Da8</id>
				<published>2010-06-30T21:19:01.000Z</published>
				<updated>2010-07-12T18:17:58.000Z</updated>
				<category scheme='http://schemas.google.com/g/2005#kind' term='http://gdata.youtube.com/schemas/2007#video'/>
				<category scheme='http://gdata.youtube.com/schemas/2007/categories.cat' term='Nonprofit' label='Nonprofits &amp; Activism'/>
				<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='trailer'/>
				<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='for'/>
				<category scheme='http://gdata.youtube.com/schemas/2007/keywords.cat' term='website'/>
				<title type='text'>Trailer for website.wmv</title>
				<content type='text'>Brand New Trailer For Our Website!!</content>
				<link rel='alternate' type='text/html' href='http://www.youtube.com/watch?v=jsvzVFL0Da8&amp;feature=youtube_gdata'/>
				<link rel='http://gdata.youtube.com/schemas/2007#video.responses' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/jsvzVFL0Da8/responses'/>
				<link rel='http://gdata.youtube.com/schemas/2007#video.related' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/jsvzVFL0Da8/related'/>
				<link rel='http://gdata.youtube.com/schemas/2007#mobile' type='text/html' href='http://m.youtube.com/details?v=jsvzVFL0Da8'/>
				<link rel='self' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/jsvzVFL0Da8'/>
				<author>
					<name>deepinsidetitanic</name>
					<uri>http://gdata.youtube.com/feeds/api/users/deepinsidetitanic</uri>
				</author>
				<gd:comments>
					<gd:feedLink href='http://gdata.youtube.com/feeds/api/videos/jsvzVFL0Da8/comments' countHint='0'/>
				</gd:comments>
				<media:group>
					<media:category label='Nonprofits &amp; Activism' scheme='http://gdata.youtube.com/schemas/2007/categories.cat'>Nonprofit</media:category>
					<media:content url='http://www.youtube.com/v/jsvzVFL0Da8?f=videos&amp;app=youtube_gdata' type='application/x-shockwave-flash' medium='video' isDefault='true' expression='full' duration='55' yt:format='5'/>
					<media:content url='rtsp://v7.cache3.c.youtube.com/CiILENy73wIaGQmvDfRSVPPLjhMYDSANFEgGUgZ2aWRlb3MM/0/0/0/video.3gp' type='video/3gpp' medium='video' expression='full' duration='55' yt:format='1'/>
					<media:content url='rtsp://v3.cache3.c.youtube.com/CiILENy73wIaGQmvDfRSVPPLjhMYESARFEgGUgZ2aWRlb3MM/0/0/0/video.3gp' type='video/3gpp' medium='video' expression='full' duration='55' yt:format='6'/>
					<media:description type='plain'>Brand New Trailer For Our Website!!</media:description>
					<media:keywords>trailer, for, website</media:keywords>
					<media:player url='http://www.youtube.com/watch?v=jsvzVFL0Da8&amp;feature=youtube_gdata'/>
					<media:restriction type='country' relationship='deny'>DE</media:restriction>
					<media:thumbnail url='http://i.ytimg.com/vi/jsvzVFL0Da8/2.jpg' height='90' width='120' time='00:00:27.500'/>
					<media:thumbnail url='http://i.ytimg.com/vi/jsvzVFL0Da8/1.jpg' height='90' width='120' time='00:00:13.750'/>
					<media:thumbnail url='http://i.ytimg.com/vi/jsvzVFL0Da8/3.jpg' height='90' width='120' time='00:00:41.250'/>
					<media:thumbnail url='http://i.ytimg.com/vi/jsvzVFL0Da8/0.jpg' height='240' width='320' time='00:00:27.500'/>
					<media:title type='plain'>Trailer for website.wmv</media:title>
					<yt:duration seconds='55'/>
				</media:group>
				<yt:statistics favoriteCount='0' viewCount='12'/>
			</entry>
			*/

			var video:YouTubeVideo = new YouTubeVideo();

			var i:int;
			var tempArray:Array;
			var tempList:XMLList;
			var tempStr:String;

			// Default namespace data -------------------
			/*FDT_IGNORE*/
			var ns:Namespace = __xml.namespace();
			default xml namespace = ns;
			/*FDT_IGNORE*/

			tempArray = __xml.child("id").toString().split("/");
			video.id = tempArray[tempArray.length - 1] as String;

			video.keywords = new Vector.<String>();
			video.categories = new Vector.<YouTubeCategory>();
			video.thumbnails = new Vector.<YouTubeThumbnail>();

			video.published = DateUtils.xsdDateTimeToDate(__xml.child("published").toString());
			video.updated = DateUtils.xsdDateTimeToDate(__xml.child("updated").toString());
			video.title = __xml.child("title").toString();
			video.content = __xml.child("content").toString();
			video.author = __xml.child("author").child("name").toString();

			tempList = __xml.child("category");
			for (i = 0; i < tempList.length(); i++) {
				tempStr = tempList[i].@scheme;
				if (tempStr == YouTubeConstants.SCHEMA_KEYWORD) {
					// It's a keywork
					video.keywords.push(tempList[i].@term);
				} else if (tempStr == YouTubeConstants.SCHEMA_CATEGORY) {
					// It's a category
					video.categories.push(new YouTubeCategory(tempList[i].@term, tempList[i].@label));
				}
			}

			/*FDT_IGNORE*/

			// GD namespace data -------------------
			var gdns:Namespace = __xml.namespace(YouTubeConstants.NAMESPACE_GD);

			video.comments = parseInt(__xml.gdns::comments.gdns::feedLink[0].@countHint, 10);

			// YT namespace data -------------------
			var ytns:Namespace = __xml.namespace(YouTubeConstants.NAMESPACE_YT);

			if (Boolean(__xml.ytns::statistics) && __xml.ytns::statistics.length() > 0) {
				video.favoriteCount = parseInt(__xml.ytns::statistics[0].@favoriteCount, 10);
				video.viewCount = parseInt(__xml.ytns::statistics[0].@viewCount, 10);
			}

			// Media namespace data -------------------
			var medians:Namespace = __xml.namespace(YouTubeConstants.NAMESPACE_MEDIA);

			tempList = __xml.medians::group.medians::thumbnail;

			for (i = 0; i < tempList.length(); i++) {
				video.thumbnails.push(new YouTubeThumbnail(tempList[i].@url, parseInt(tempList[i].@height, 10), parseInt(tempList[i].@width), YouTubeDataUtils.fromStringToSeconds(tempList[i].@time)));
			}

			// Mixed namespace data -------------------

			video.duration = parseInt(__xml.medians::group[0].ytns::duration.@seconds);

			default xml namespace = new Namespace(""); // WTF! one needs this otherwise the function below fails!

			/*FDT_IGNORE*/

			return video;
		}
	}
}
