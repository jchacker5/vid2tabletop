import { google } from "googleapis";

const youtube = google.youtube("v3");

interface YouTubeVideo {
  id: string;
  title: string;
  description: string;
  thumbnailUrl: string;
  publishedAt: string;
}

export async function searchNBAVideos(query: string): Promise<YouTubeVideo[]> {
  try {
    const response = await youtube.search.list({
      key: process.env.YOUTUBE_API_KEY,
      part: ["snippet"],
      q: `NBA ${query}`,
      type: ["video"],
      maxResults: 10,
      videoType: "any",
      order: "relevance",
    });

    if (!response.data.items) {
      return [];
    }

    return response.data.items.map((item) => ({
      id: item.id?.videoId || "",
      title: item.snippet?.title || "",
      description: item.snippet?.description || "",
      thumbnailUrl: item.snippet?.thumbnails?.medium?.url || "",
      publishedAt: item.snippet?.publishedAt || "",
    }));
  } catch (error) {
    console.error("Error searching YouTube videos:", error);
    throw new Error("Failed to search YouTube videos");
  }
}

export async function getVideoDetails(
  videoId: string
): Promise<YouTubeVideo | null> {
  try {
    const response = await youtube.videos.list({
      key: process.env.YOUTUBE_API_KEY,
      part: ["snippet"],
      id: [videoId],
    });

    if (!response.data.items?.[0]) {
      return null;
    }

    const video = response.data.items[0];
    return {
      id: video.id || "",
      title: video.snippet?.title || "",
      description: video.snippet?.description || "",
      thumbnailUrl: video.snippet?.thumbnails?.medium?.url || "",
      publishedAt: video.snippet?.publishedAt || "",
    };
  } catch (error) {
    console.error("Error getting video details:", error);
    throw new Error("Failed to get video details");
  }
}
