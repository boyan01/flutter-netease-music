package tech.soit.quiet.model.vo

import android.graphics.Bitmap
import android.os.Parcelable
import java.io.Serializable

abstract class Music : Parcelable, Serializable {

    abstract fun getId(): Long

    abstract fun getTitle(): String

    abstract fun getSubTitle(): String

    abstract fun getPlayUrl(): String

    abstract fun isFavorite(): Boolean

    abstract fun getCoverBitmap(): Bitmap?

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        other as Music

        if (getId() != other.getId()) return false

        return true
    }

    override fun toString(): String {
        return "{id : ${getId()} , title : ${getTitle()}}"
    }

    override fun hashCode(): Int {
        return getId().hashCode()
    }


}