"use client";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useState } from "react";
import { toast } from "sonner";

interface YoutubeInputProps {
  onVideoSubmit: (videoId: string) => Promise<void>;
}

export function YoutubeInput({ onVideoSubmit }: YoutubeInputProps) {
  const [url, setUrl] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);

  function extractYoutubeId(url: string): string | null {
    const regex =
      /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/;
    const match = url.match(regex);
    return match ? match[1] : null;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const videoId = extractYoutubeId(url);

    if (!videoId) {
      toast.error("Please enter a valid YouTube URL");
      return;
    }

    try {
      setIsProcessing(true);
      await onVideoSubmit(videoId);
      toast.success("Video processing started");
    } catch (error) {
      toast.error("Failed to process video");
    } finally {
      setIsProcessing(false);
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="flex flex-col space-y-2">
        <label htmlFor="youtube-url" className="text-sm font-medium">
          NBA Game YouTube URL
        </label>
        <Input
          id="youtube-url"
          type="text"
          placeholder="https://youtube.com/watch?v=..."
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          className="w-full"
        />
      </div>
      <Button type="submit" disabled={isProcessing} className="w-full">
        {isProcessing ? "Processing..." : "Convert to Tabletop"}
      </Button>
    </form>
  );
}
