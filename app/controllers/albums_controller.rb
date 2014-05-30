class AlbumsController < ApplicationController
  def new
  end

  def create
    #@albums = Album.all
    @album = Album.create(album_params)

    respond_to do |format|
      if @album.save
        format.json { render json: @album, status: :created }
        # album_release
      else
        format.json { render json: @album.errors, status: :unprocessable_entity}
      end
    end

  end

  def recent_albums
    #SHOWS USER's BAND's ALBUMS RELEASED WITHIN THE PAST MONTH
    band_ids = current_user.bands.map(&:id)
    @albums = Album.where(band_id: band_ids)
    #binding.pry
    @albumshash=[]
    @albums.each do |i|
      if (i["releaseDate"] > 1.month.ago) && (i["releaseDate"] < Time.now)
        @albumshash.push(i["name"] + "; " + i["releaseDate"])
      end
    end
    respond_to do |format|
      format.json { render json: @albumshash, status: :ok }
    end
  end

  def album_release
    band_ids = current_user.bands.map(&:id)
    @albums = Album.where(band_id: band_ids)

    emailalbums = []
    @albums.each do |i|

      if (i["releaseDate"]) > Time.now
        emailalbums.push(i["name"])
        #binding.pry
        AlbumMailer.album_email(current_user.email,i["name"], i["releaseDate"]).deliver
      else

      end

    end
  end
  private
  def album_params
    params.require(:album).permit(:name, :releaseDate, :band_id)
  end
end
